import 'dart:async';
import 'dart:convert';

import '../../logging/log_level.dart';
import '../../logging/logger.dart';
import '../../logging/logger_extensions.dart';
import '../../system/exceptions/operation_cancelled_exception.dart';
import '../../system/threading/cancellation_token.dart';
import 'chat_message.dart';
import 'chat_options.dart';
import 'chat_response.dart';
import 'chat_response_update.dart';
import 'delegating_chat_client.dart';

/// A delegating chat client that logs chat operations to an [Logger].
///
/// At [LogLevel.debug], the method name is logged at the start and end of
/// each call. At [LogLevel.trace], the messages, options, response, and
/// streaming updates are also logged. Errors and cancellations are logged
/// at [LogLevel.error] and [LogLevel.debug] respectively.
class LoggingChatClient extends DelegatingChatClient {
  /// Creates a new [LoggingChatClient].
  ///
  /// [innerClient] is the underlying client to delegate to.
  /// [logger] is the logger used to record information.
  LoggingChatClient(
    super.innerClient, {
    required Logger logger,
  }) : _logger = logger;

  final Logger _logger;

  /// The [JsonEncoder] used to serialize log data.
  ///
  /// Defaults to a pretty-printing encoder with two-space indentation.
  JsonEncoder jsonEncoder = const JsonEncoder.withIndent('  ');

  @override
  Future<ChatResponse> getResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    _logInvoked('getChatResponse');
    _logInvokedSensitive('getChatResponse', messages, options);

    try {
      final response = await super.getResponse(
        messages: messages,
        options: options,
        cancellationToken: cancellationToken,
      );

      _logCompleted('getChatResponse');
      _logCompletedSensitive('getChatResponse', response);

      return response;
    } on OperationCanceledException {
      _logInvocationCanceled('getChatResponse');
      rethrow;
    } catch (e) {
      _logInvocationFailed('getChatResponse', e);
      rethrow;
    }
  }

  @override
  Stream<ChatResponseUpdate> getStreamingResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) {
    Stream<ChatResponseUpdate> stream() async* {
      _logInvoked('getStreamingChatResponse');
      _logInvokedSensitive('getStreamingChatResponse', messages, options);

      try {
        await for (final update in super.getStreamingResponse(
          messages: messages,
          options: options,
          cancellationToken: cancellationToken,
        )) {
          _logStreamingUpdateSensitive(update);
          yield update;
        }

        _logCompleted('getStreamingResponse');
      } on OperationCanceledException {
        _logInvocationCanceled('getStreamingResponse');
        rethrow;
      } catch (e) {
        _logInvocationFailed('getStreamingResponse', e);
        rethrow;
      }
    }

    return stream();
  }

  void _logInvoked(String methodName) {
    if (_logger.isEnabled(LogLevel.debug)) {
      _logger.logDebug('$methodName invoked.');
    }
  }

  void _logInvokedSensitive(
    String methodName,
    Iterable<ChatMessage> messages,
    ChatOptions? options,
  ) {
    if (_logger.isEnabled(LogLevel.trace)) {
      _logger.logTrace(
        '$methodName invoked. '
        'Messages: ${_asJson(messages.map(_messageToMap).toList())}. '
        'Options: '
        '${options != null ? _asJson(_optionsToMap(options)) : 'null'}.',
      );
    }
  }

  void _logCompleted(String methodName) {
    if (_logger.isEnabled(LogLevel.debug)) {
      _logger.logDebug('$methodName completed.');
    }
  }

  void _logCompletedSensitive(String methodName, ChatResponse response) {
    if (_logger.isEnabled(LogLevel.trace)) {
      _logger.logTrace(
        '$methodName completed. '
        'Response: ${_asJson(_responseToMap(response))}.',
      );
    }
  }

  void _logStreamingUpdateSensitive(ChatResponseUpdate update) {
    if (_logger.isEnabled(LogLevel.trace)) {
      _logger.logTrace(
        'getStreamingChatResponse received update. '
        'Update: ${_asJson(_updateToMap(update))}.',
      );
    }
  }

  void _logInvocationCanceled(String methodName) {
    if (_logger.isEnabled(LogLevel.debug)) {
      _logger.logDebug('$methodName canceled.');
    }
  }

  void _logInvocationFailed(String methodName, Object error) {
    _logger.logError(
      '$methodName failed.',
      error: error,
    );
  }

  String _asJson(Object? value) {
    try {
      return jsonEncoder.convert(value);
    } catch (_) {
      return value.toString();
    }
  }

  static Map<String, Object?> _messageToMap(ChatMessage message) => {
        'role': message.role.value,
        if (message.authorName != null) 'authorName': message.authorName,
        'contents': message.contents.map((c) => c.toString()).toList(),
      };

  static Map<String, Object?> _optionsToMap(ChatOptions options) => {
        if (options.modelId != null) 'modelId': options.modelId,
        if (options.temperature != null) 'temperature': options.temperature,
        if (options.topP != null) 'topP': options.topP,
        if (options.topK != null) 'topK': options.topK,
        if (options.maxOutputTokens != null)
          'maxOutputTokens': options.maxOutputTokens,
      };

  static Map<String, Object?> _responseToMap(ChatResponse response) => {
        if (response.responseId != null) 'responseId': response.responseId,
        if (response.modelId != null) 'modelId': response.modelId,
        if (response.finishReason != null)
          'finishReason': response.finishReason.toString(),
        'messages': response.messages.map(_messageToMap).toList(),
      };

  static Map<String, Object?> _updateToMap(ChatResponseUpdate update) => {
        if (update.role != null) 'role': update.role!.value,
        if (update.authorName != null) 'authorName': update.authorName,
        'contents': update.contents.map((c) => c.toString()).toList(),
        if (update.finishReason != null)
          'finishReason': update.finishReason.toString(),
        if (update.modelId != null) 'modelId': update.modelId,
      };
}
