import 'dart:async';

import 'package:extensions/annotations.dart';

import '../../logging/logger.dart';
import '../../logging/logger_extensions.dart';
import '../../system/threading/cancellation_token.dart';
import '../ai_content.dart';
import '../chat_completion/function_invoking_chat_client.dart'
    show FunctionInvocationResult, FunctionInvocationStatus;
import '../function_call_content.dart';
import '../function_result_content.dart';
import '../functions/ai_function.dart';
import '../functions/ai_function_arguments.dart';
import '../tools/ai_tool.dart';
import 'create_conversation_item_realtime_client_message.dart';
import 'create_response_realtime_client_message.dart';
import 'function_invoking_realtime_client.dart';
import 'realtime_client_message.dart';
import 'realtime_client_session.dart';
import 'realtime_conversation_item.dart';
import 'realtime_server_message.dart';
import 'realtime_server_message_type.dart';
import 'realtime_session_options.dart';
import 'response_output_item_realtime_server_message.dart';

/// A [RealtimeClientSession] that automatically invokes functions requested by
/// the model over the server-message stream.
///
/// When a [ResponseOutputItemRealtimeServerMessage] with type
/// [RealtimeServerMessageType.responseOutputItemDone] carries one or more
/// [FunctionCallContent], the matching [AIFunction] is invoked and a
/// [FunctionResultContent] is sent back to the inner session, repeating until
/// the model stops requesting functions or a stop condition is met.
///
/// This is an experimental feature.
@Source(
  name: 'FunctionInvokingRealtimeClientSession.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI/Realtime/',
  commit: '2e537166e4231e50cceb66832b9dfd1382e24d1b',
)
class FunctionInvokingRealtimeClientSession implements RealtimeClientSession {
  /// Creates a new [FunctionInvokingRealtimeClientSession] wrapping
  /// [innerSession] and using [client] for configuration.
  FunctionInvokingRealtimeClientSession(this._innerSession, this._client);

  final RealtimeClientSession _innerSession;
  final FunctionInvokingRealtimeClient _client;

  Logger? get _logger => _client.logger;

  @override
  RealtimeSessionOptions? get options => _innerSession.options;

  @override
  Future<void> send(
    RealtimeClientMessage message, {
    CancellationToken? cancellationToken,
  }) =>
      _innerSession.send(message, cancellationToken: cancellationToken);

  @override
  T? getService<T>({Object? key}) => _innerSession.getService<T>(key: key);

  @override
  Future<void> disposeAsync() => _innerSession.disposeAsync();

  @override
  Stream<RealtimeServerMessage> getStreamingResponse({
    CancellationToken? cancellationToken,
  }) async* {
    var iterations = 0;
    var consecutiveErrors = 0;

    await for (final message in _innerSession.getStreamingResponse(
      cancellationToken: cancellationToken,
    )) {
      final functionCalls = _extractFunctionCalls(message);

      // Always yield so consumers can observe function calls and other events.
      yield message;

      if (functionCalls.isEmpty) {
        continue;
      }

      // Once the iteration budget is exhausted, keep streaming but stop
      // invoking so the long-lived session is not torn down.
      if (iterations >= _client.maximumIterationsPerRequest) {
        _logger?.logDebug(
          'Maximum function-invocation iterations '
          '(${_client.maximumIterationsPerRequest}) reached.',
        );
        continue;
      }

      iterations++;
      final results = await _invokeFunctions(functionCalls, cancellationToken);

      final hasErrors =
          results.any((r) => r.status == FunctionInvocationStatus.exception);
      if (hasErrors) {
        consecutiveErrors++;
        if (consecutiveErrors >= _client.maximumConsecutiveErrorsPerRequest) {
          return;
        }
      } else {
        consecutiveErrors = 0;
      }

      if (results.any((r) => r.terminate)) {
        return;
      }

      for (final resultMessage in _createResultMessages(results)) {
        await _innerSession.send(
          resultMessage,
          cancellationToken: cancellationToken,
        );
      }
    }
  }

  List<FunctionCallContent> _extractFunctionCalls(RealtimeServerMessage msg) {
    if (msg is ResponseOutputItemRealtimeServerMessage &&
        msg.type == RealtimeServerMessageType.responseOutputItemDone) {
      final item = msg.item;
      if (item != null) {
        return item.contents.whereType<FunctionCallContent>().toList();
      }
    }
    return const <FunctionCallContent>[];
  }

  List<AITool> _getAllTools() {
    final tools = <AITool>[];
    final optionTools = _innerSession.options?.tools;
    if (optionTools != null) {
      tools.addAll(optionTools);
    }
    if (_client.additionalTools != null) {
      tools.addAll(_client.additionalTools!);
    }
    return tools;
  }

  Future<List<FunctionInvocationResult>> _invokeFunctions(
    List<FunctionCallContent> calls,
    CancellationToken? cancellationToken,
  ) async {
    final tools = _getAllTools();

    if (_client.allowConcurrentInvocation) {
      return Future.wait(
        calls.map((call) => _invokeFunction(call, tools, cancellationToken)),
      );
    }

    final results = <FunctionInvocationResult>[];
    for (final call in calls) {
      results.add(await _invokeFunction(call, tools, cancellationToken));
    }
    return results;
  }

  Future<FunctionInvocationResult> _invokeFunction(
    FunctionCallContent call,
    List<AITool> tools,
    CancellationToken? cancellationToken,
  ) async {
    AIFunction? tool;
    for (final candidate in tools.whereType<AIFunction>()) {
      if (candidate.name == call.name) {
        tool = candidate;
        break;
      }
    }

    if (tool == null) {
      final errorMessage = 'Function "${call.name}" not found.';
      _logger?.logError(errorMessage);

      return FunctionInvocationResult(
        status: FunctionInvocationStatus.notFound,
        callContent: call,
        result: errorMessage,
        terminate: _client.terminateOnUnknownCalls,
      );
    }

    try {
      final arguments = AIFunctionArguments(call.arguments);
      final result = await tool.invoke(
        arguments,
        cancellationToken: cancellationToken,
      );

      return FunctionInvocationResult(
        status: FunctionInvocationStatus.ranToCompletion,
        callContent: call,
        result: result,
      );
    } catch (e) {
      _logger?.logError(
        'Function "${call.name}" threw an exception.',
        error: e,
      );

      final errorResult = _client.includeDetailedErrors
          ? e.toString()
          : 'An error occurred invoking the function.';

      return FunctionInvocationResult(
        status: FunctionInvocationStatus.exception,
        callContent: call,
        result: errorResult,
        exception: e,
      );
    }
  }

  List<RealtimeClientMessage> _createResultMessages(
    List<FunctionInvocationResult> results,
  ) {
    final messages = <RealtimeClientMessage>[];

    for (final result in results) {
      final content = FunctionResultContent(
        callId: result.callContent.callId,
        name: result.callContent.name,
        result: result.result,
        exception: result.exception is Exception
            ? result.exception as Exception
            : null,
      );

      final item = RealtimeConversationItem(<AIContent>[content]);
      messages.add(CreateConversationItemRealtimeClientMessage(item));
    }

    // Ask the model to respond to the function results. Output modalities are
    // intentionally left unset so the session defaults apply.
    messages.add(CreateResponseRealtimeClientMessage());

    return messages;
  }
}
