import 'dart:developer' as developer;

import 'package:extensions/annotations.dart';

import '../../system/threading/cancellation_token.dart';
import '../open_telemetry_consts.dart';
import 'delegating_text_to_speech_client.dart';
import 'text_to_speech_options.dart';
import 'text_to_speech_response.dart';
import 'text_to_speech_response_update.dart';

/// A [DelegatingTextToSpeechClient] that records OpenTelemetry spans.
@Source(
  name: 'OpenTelemetryTextToSpeechClient.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI/TextToSpeech/',
)
class OpenTelemetryTextToSpeechClient extends DelegatingTextToSpeechClient {
  /// Creates a new [OpenTelemetryTextToSpeechClient].
  OpenTelemetryTextToSpeechClient(super.innerClient,
      {this.modelId, this.system});

  /// The model ID to record on spans.
  final String? modelId;

  /// The AI system name (e.g. `"openai"`).
  final String? system;

  @override
  Future<TextToSpeechResponse> getAudio(
    String text, {
    TextToSpeechOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    developer.Timeline.startSync(
      OpenTelemetryConsts.textToSpeechSpanName,
      arguments: _buildArguments(options),
    );
    try {
      final result = await super.getAudio(
        text,
        options: options,
        cancellationToken: cancellationToken,
      );
      developer.Timeline.finishSync();
      return result;
    } catch (e) {
      developer.Timeline.finishSync();
      rethrow;
    }
  }

  @override
  Stream<TextToSpeechResponseUpdate> getStreamingAudio(
    String text, {
    TextToSpeechOptions? options,
    CancellationToken? cancellationToken,
  }) async* {
    developer.Timeline.startSync(
      '${OpenTelemetryConsts.textToSpeechSpanName}.streaming',
      arguments: _buildArguments(options),
    );
    try {
      yield* super.getStreamingAudio(
        text,
        options: options,
        cancellationToken: cancellationToken,
      );
      developer.Timeline.finishSync();
    } catch (e) {
      developer.Timeline.finishSync();
      rethrow;
    }
  }

  Map<String, Object?> _buildArguments(TextToSpeechOptions? options) => {
        if (system != null) OpenTelemetryConsts.systemKey: system,
        OpenTelemetryConsts.requestModelKey:
            options?.modelId ?? modelId ?? 'unknown',
      };
}
