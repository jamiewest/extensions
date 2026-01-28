import 'dart:async';
import 'dart:convert';

import '../../logging/log_level.dart';
import '../../logging/logger.dart';
import '../../logging/logger_extensions.dart';
import '../../system/exceptions/operation_cancelled_exception.dart';
import '../../system/threading/cancellation_token.dart';
import 'delegating_speech_to_text_client.dart';
import 'speech_to_text_client.dart';

/// A delegating speech-to-text client that logs operations to a [Logger].
///
/// This is an experimental feature.
class LoggingSpeechToTextClient extends DelegatingSpeechToTextClient {
  /// Creates a new [LoggingSpeechToTextClient].
  LoggingSpeechToTextClient(
    super.innerClient, {
    required Logger logger,
  }) : _logger = logger;

  final Logger _logger;

  /// The [JsonEncoder] used to serialize log data.
  JsonEncoder jsonEncoder = const JsonEncoder.withIndent('  ');

  @override
  Future<SpeechToTextResponse> getText({
    required Stream<List<int>> stream,
    SpeechToTextOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    if (_logger.isEnabled(LogLevel.debug)) {
      _logger.logDebug('getText invoked.');
    }

    if (_logger.isEnabled(LogLevel.trace)) {
      _logger.logTrace(
        'getText invoked. '
        'Options: ${options != null ? _asJson(_optionsToMap(options)) : 'null'}.',
      );
    }

    try {
      final response = await super.getText(
        stream: stream,
        options: options,
        cancellationToken: cancellationToken,
      );

      if (_logger.isEnabled(LogLevel.debug)) {
        _logger.logDebug('getText completed.');
      }

      if (_logger.isEnabled(LogLevel.trace)) {
        _logger.logTrace(
          'getText completed. '
          'Response: ${_asJson(_responseToMap(response))}.',
        );
      }

      return response;
    } on OperationCanceledException {
      if (_logger.isEnabled(LogLevel.debug)) {
        _logger.logDebug('getText canceled.');
      }
      rethrow;
    } catch (e) {
      _logger.logError('getText failed.', error: e);
      rethrow;
    }
  }

  @override
  Stream<SpeechToTextResponse> getStreamingText({
    required Stream<List<int>> stream,
    SpeechToTextOptions? options,
    CancellationToken? cancellationToken,
  }) {
    Stream<SpeechToTextResponse> streamFn() async* {
      if (_logger.isEnabled(LogLevel.debug)) {
        _logger.logDebug('getStreamingText invoked.');
      }

      if (_logger.isEnabled(LogLevel.trace)) {
        _logger.logTrace(
          'getStreamingText invoked. '
          'Options: ${options != null ? _asJson(_optionsToMap(options)) : 'null'}.',
        );
      }

      try {
        await for (final update in super.getStreamingText(
          stream: stream,
          options: options,
          cancellationToken: cancellationToken,
        )) {
          if (_logger.isEnabled(LogLevel.trace)) {
            _logger.logTrace(
              'getStreamingText received update. '
              'Update: ${_asJson(_responseToMap(update))}.',
            );
          }
          yield update;
        }

        if (_logger.isEnabled(LogLevel.debug)) {
          _logger.logDebug('getStreamingText completed.');
        }
      } on OperationCanceledException {
        if (_logger.isEnabled(LogLevel.debug)) {
          _logger.logDebug('getStreamingText canceled.');
        }
        rethrow;
      } catch (e) {
        _logger.logError('getStreamingText failed.', error: e);
        rethrow;
      }
    }

    return streamFn();
  }

  String _asJson(Object? value) {
    try {
      return jsonEncoder.convert(value);
    } catch (_) {
      return value.toString();
    }
  }

  static Map<String, Object?> _optionsToMap(SpeechToTextOptions options) => {
        if (options.modelId != null) 'modelId': options.modelId,
        if (options.speechLanguage != null)
          'speechLanguage': options.speechLanguage,
        if (options.textLanguage != null) 'textLanguage': options.textLanguage,
      };

  static Map<String, Object?> _responseToMap(SpeechToTextResponse response) =>
      {
        if (response.responseId != null) 'responseId': response.responseId,
        if (response.modelId != null) 'modelId': response.modelId,
        'text': response.text,
      };
}
