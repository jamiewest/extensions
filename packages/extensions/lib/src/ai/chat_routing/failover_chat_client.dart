import 'dart:async';

import 'package:extensions/annotations.dart';
import 'package:meta/meta.dart';

import '../../system/threading/cancellation_token.dart';
import '../chat_completion/chat_message.dart';
import '../chat_completion/chat_options.dart';
import '../chat_completion/chat_response.dart';
import '../chat_completion/chat_response_update.dart';
import 'failover_chat_client_attempt.dart';
import 'routing_chat_client.dart';
import 'routing_context.dart';

/// Provides a template for a [RoutingChatClient] that can select another
/// client after an invocation fails.
///
/// The client for each attempt is supplied by [selectClient]. After an
/// invocation, [onRoutingUpdate] reports the concrete attempt and whether
/// another selection will follow. An uncanceled failure causes another
/// selection only when it happened before any streaming output was exposed
/// and the attempt limit permits it.
///
/// The base class owns invocation, streaming commitment, attempt limits,
/// and attempt reporting. Derived classes own client selection, policy
/// state, selection-failure cleanup, and the lifetime of clients they
/// retain.
///
/// Once a streaming response is being listened to, abandoning it without
/// cancellation prevents both inner stream cleanup and the terminal
/// routing update.
///
/// Upstream marks the ChatRouting family `[Experimental]`; the surface
/// may change as upstream stabilizes.
@Source(
  name: 'FailoverChatClient.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI/ChatRouting/',
)
abstract class FailoverChatClient extends RoutingChatClient {
  /// Creates a new [FailoverChatClient].
  FailoverChatClient();

  int? _maximumAttemptsPerRequest;

  /// The maximum number of client invocations permitted for one request.
  ///
  /// A positive attempt limit, or `null` to leave termination to client
  /// selection and request cancellation. The default is `null`.
  ///
  /// The value is captured when a non-streaming request begins or when a
  /// streaming response is first listened to. Changing it does not affect
  /// requests or streams already in progress.
  int? get maximumAttemptsPerRequest => _maximumAttemptsPerRequest;

  set maximumAttemptsPerRequest(int? value) {
    if (value != null && value <= 0) {
      throw ArgumentError.value(
        value,
        'maximumAttemptsPerRequest',
        'The attempt limit must be positive.',
      );
    }
    _maximumAttemptsPerRequest = value;
  }

  /// Invoked after a client invocation completes, fails, or is abandoned.
  ///
  /// [isTerminal] is `true` when the base will not select another client
  /// after this method returns successfully.
  ///
  /// The default implementation performs no operation. A nonterminal
  /// update always contains an uncanceled, pre-output failed attempt.
  /// State changes made by the override are visible to the next call to
  /// [selectClient].
  ///
  /// This method is invoked once after each selected-client invocation,
  /// whether it completes, fails, or is abandoned. Selection failures are
  /// not reported. A selector that retains request-scoped state must
  /// release it before throwing; a request may therefore end without a
  /// terminal update when selection fails.
  ///
  /// Exceptions from this method propagate to the caller. A terminal
  /// update exception replaces the response or exception already produced
  /// by the request. A nonterminal update exception stops routing without
  /// another update. An override that retains per-request state must
  /// release that state before throwing because no later update is made
  /// after an update exception.
  Future<void> onRoutingUpdate(
    RoutingContext context,
    FailoverChatClientAttempt attempt, {
    required bool isTerminal,
    CancellationToken? cancellationToken,
  }) async {}

  @override
  @nonVirtual
  Future<ChatResponse> getResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    final context = RoutingContext(messages, options);
    final maximumAttempts = maximumAttemptsPerRequest;
    var attemptCount = 0;

    while (true) {
      final selectedClient = await selectClient(context, cancellationToken);
      final attemptOptions = options?.clone();

      attemptCount++;
      ChatResponse? response;
      Object? exception;
      StackTrace? stackTrace;
      final stopwatch = Stopwatch()..start();

      try {
        response = await selectedClient.getResponse(
          messages: context.messages,
          options: attemptOptions,
          cancellationToken: cancellationToken,
        );
      } catch (e, st) {
        exception = e;
        stackTrace = st;
      }

      stopwatch.stop();
      final attempt = FailoverChatClientAttempt(
        client: selectedClient,
        exception: exception,
        stackTrace: stackTrace,
        duration: stopwatch.elapsed,
        responseCompleted: exception == null,
        outputCommitted: false,
      );
      final cancellationRequested = exception != null &&
          (cancellationToken?.isCancellationRequested ?? false);
      final isTerminal = exception == null ||
          cancellationRequested ||
          (maximumAttempts != null && attemptCount >= maximumAttempts);

      await onRoutingUpdate(
        context,
        attempt,
        isTerminal: isTerminal,
        cancellationToken: cancellationToken,
      );

      if (exception == null) {
        return response!;
      }

      if (cancellationRequested) {
        cancellationToken?.throwIfCancellationRequested();
      }

      if (isTerminal) {
        Error.throwWithStackTrace(exception, stackTrace ?? StackTrace.current);
      }
    }
  }

  @override
  @nonVirtual
  Stream<ChatResponseUpdate> getStreamingResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async* {
    final context = RoutingContext(messages, options);
    final maximumAttempts = maximumAttemptsPerRequest;
    var attemptCount = 0;

    while (true) {
      final selectedClient = await selectClient(context, cancellationToken);
      final attemptOptions = options?.clone();

      attemptCount++;
      final reachedAttemptLimit =
          maximumAttempts != null && attemptCount >= maximumAttempts;
      StreamIterator<ChatResponseUpdate>? iterator;
      Duration? timeToFirstUpdate;
      bool hasCurrent;

      final stopwatch = Stopwatch()..start();
      try {
        iterator = StreamIterator(selectedClient.getStreamingResponse(
          messages: context.messages,
          options: attemptOptions,
          cancellationToken: cancellationToken,
        ));
        hasCurrent = await iterator.moveNext();
      } catch (e, st) {
        stopwatch.stop();
        var exception = e;
        var stackTrace = st;
        if (iterator != null) {
          try {
            await iterator.cancel();
          } catch (e2, st2) {
            exception = e2;
            stackTrace = st2;
          }
        }

        final attempt = FailoverChatClientAttempt(
          client: selectedClient,
          exception: exception,
          stackTrace: stackTrace,
          duration: stopwatch.elapsed,
          responseCompleted: false,
          outputCommitted: false,
        );
        final cancellationRequested =
            cancellationToken?.isCancellationRequested ?? false;
        final isTerminal = cancellationRequested || reachedAttemptLimit;

        await onRoutingUpdate(
          context,
          attempt,
          isTerminal: isTerminal,
          cancellationToken: cancellationToken,
        );

        if (cancellationRequested) {
          cancellationToken?.throwIfCancellationRequested();
        }

        if (isTerminal) {
          Error.throwWithStackTrace(exception, stackTrace);
        }

        continue;
      }

      stopwatch.stop();
      var responseCompleted = false;
      var outputCommitted = false;
      var isTerminalAttempt = false;
      Object? terminalException;
      StackTrace? terminalStackTrace;

      try {
        while (hasCurrent) {
          final current = iterator.current;
          timeToFirstUpdate ??= stopwatch.elapsed;
          outputCommitted = true;
          yield current;

          stopwatch.start();
          try {
            hasCurrent = await iterator.moveNext();
          } catch (e, st) {
            terminalException = e;
            terminalStackTrace = st;
            break;
          } finally {
            stopwatch.stop();
          }
        }

        responseCompleted = terminalException == null;
      } finally {
        try {
          await iterator.cancel();
        } catch (e, st) {
          terminalException = e;
          terminalStackTrace = st;
        }

        final attempt = FailoverChatClientAttempt(
          client: selectedClient,
          exception: terminalException,
          stackTrace: terminalStackTrace,
          duration: stopwatch.elapsed,
          timeToFirstUpdate: timeToFirstUpdate,
          responseCompleted: responseCompleted && terminalException == null,
          outputCommitted: outputCommitted,
        );
        final cancellationRequested = terminalException != null &&
            (cancellationToken?.isCancellationRequested ?? false);
        isTerminalAttempt = attempt.responseCompleted ||
            outputCommitted ||
            cancellationRequested ||
            reachedAttemptLimit;

        await onRoutingUpdate(
          context,
          attempt,
          isTerminal: isTerminalAttempt,
          cancellationToken: cancellationToken,
        );

        if (terminalException != null) {
          if (cancellationRequested) {
            cancellationToken?.throwIfCancellationRequested();
          }

          if (isTerminalAttempt) {
            Error.throwWithStackTrace(
              terminalException,
              terminalStackTrace ?? StackTrace.current,
            );
          }
        }
      }

      if (!isTerminalAttempt) {
        continue;
      }

      return;
    }
  }
}
