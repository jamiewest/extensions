import 'dart:developer' as developer;

import 'package:extensions/annotations.dart';

import '../../system/threading/cancellation_token.dart';
import 'delegating_text_to_speech_client.dart';
import 'text_to_speech_options.dart';
import 'text_to_speech_response.dart';
import 'text_to_speech_response_update.dart';

/// A [DelegatingTextToSpeechClient] that logs requests and responses.
///
/// This is an experimental feature.
@Source(
  name: 'LoggingTextToSpeechClient.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI/TextToSpeech/',
)
class LoggingTextToSpeechClient extends DelegatingTextToSpeechClient {
  /// Creates a new [LoggingTextToSpeechClient].
  LoggingTextToSpeechClient(super.innerClient, {String? loggerName})
      : _loggerName = loggerName ?? 'TextToSpeechClient';

  final String _loggerName;

  @override
  Future<TextToSpeechResponse> getAudio(
    String text, {
    TextToSpeechOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    developer.log(
      'GetAudio invoked',
      name: _loggerName,
      level: 500,
    );
    try {
      final response = await super.getAudio(
        text,
        options: options,
        cancellationToken: cancellationToken,
      );
      developer.log(
        'GetAudio succeeded',
        name: _loggerName,
        level: 500,
      );
      return response;
    } catch (e, s) {
      developer.log(
        'GetAudio failed',
        name: _loggerName,
        level: 1000,
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  @override
  Stream<TextToSpeechResponseUpdate> getStreamingAudio(
    String text, {
    TextToSpeechOptions? options,
    CancellationToken? cancellationToken,
  }) async* {
    developer.log(
      'GetStreamingAudio invoked',
      name: _loggerName,
      level: 500,
    );
    try {
      yield* super.getStreamingAudio(
        text,
        options: options,
        cancellationToken: cancellationToken,
      );
    } catch (e, s) {
      developer.log(
        'GetStreamingAudio failed',
        name: _loggerName,
        level: 1000,
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }
}
