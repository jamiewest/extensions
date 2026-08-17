import 'dart:async';

import '../../logging/logger.dart';
import '../../logging/logger_extensions.dart';
import '../../system/threading/cancellation_token.dart';
import '../ai_content.dart';
import '../chat_completion/function_invoking_chat_client.dart'
    show FunctionInvocationResult, FunctionInvocationStatus;
import '../common/function_invocation_processor.dart';
import '../function_call_content.dart';
import '../function_result_content.dart';
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
  }) => _innerSession.send(message, cancellationToken: cancellationToken);

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

      final hasErrors = results.any(
        (r) => r.status == FunctionInvocationStatus.exception,
      );
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
  ) {
    final tools = _getAllTools();

    return FunctionInvocationProcessor(logger: _logger).processFunctionCalls(
      calls,
      findTool: (name) {
        for (final tool in tools) {
          if (tool.name == name) {
            return tool;
          }
        }
        return null;
      },
      allowConcurrentInvocation: _client.allowConcurrentInvocation,
      includeDetailedErrors: _client.includeDetailedErrors,
      terminateOnUnknownCalls: _client.terminateOnUnknownCalls,
      cancellationToken: cancellationToken,
    );
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
