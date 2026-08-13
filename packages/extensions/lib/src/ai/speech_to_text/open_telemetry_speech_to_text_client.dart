import 'dart:developer' as developer;

import 'package:extensions/annotations.dart';

import '../../system/threading/cancellation_token.dart';
import '../common/telemetry_helpers.dart';
import '../open_telemetry_consts.dart';
import 'delegating_speech_to_text_client.dart';
import 'speech_to_text_client.dart';

/// A [DelegatingSpeechToTextClient] that records OpenTelemetry spans.
///
/// This implementation uses `dart:developer` timeline events. To connect
/// it to a real OpenTelemetry SDK, subclass and wrap the transcription
/// methods.
///
/// This is an experimental feature.
@Source(
  name: 'OpenTelemetrySpeechToTextClient.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI/SpeechToText/',
)
class OpenTelemetrySpeechToTextClient extends DelegatingSpeechToTextClient {
  /// Creates a new [OpenTelemetrySpeechToTextClient].
  OpenTelemetrySpeechToTextClient(
    super.innerClient, {
    this.modelId,
    this.system,
    bool? enableSensitiveData,
  }) : enableSensitiveData =
           enableSensitiveData ?? TelemetryHelpers.enableSensitiveDataDefault;

  /// The model ID to record on spans (overrides per-request model).
  final String? modelId;

  /// The AI system name (e.g. `"openai"`).
  final String? system;

  /// Whether potentially sensitive information (such as message
  /// content) may be recorded on spans.
  ///
  /// The base implementation records no sensitive attributes;
  /// subclasses that connect a real OpenTelemetry SDK should honor
  /// this flag when recording input/output messages. Defaults to
  /// [TelemetryHelpers.enableSensitiveDataDefault].
  final bool enableSensitiveData;

  @override
  Future<SpeechToTextResponse> getText({
    required Stream<List<int>> stream,
    SpeechToTextOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    developer.Timeline.startSync(
      OpenTelemetryConsts.speechToTextSpanName,
      arguments: _buildArguments(options),
    );
    try {
      final response = await super.getText(
        stream: stream,
        options: options,
        cancellationToken: cancellationToken,
      );
      developer.Timeline.finishSync();
      return response;
    } catch (e) {
      developer.Timeline.finishSync();
      rethrow;
    }
  }

  @override
  Stream<SpeechToTextResponse> getStreamingText({
    required Stream<List<int>> stream,
    SpeechToTextOptions? options,
    CancellationToken? cancellationToken,
  }) async* {
    developer.Timeline.startSync(
      '${OpenTelemetryConsts.speechToTextSpanName}.streaming',
      arguments: _buildArguments(options),
    );
    try {
      yield* super.getStreamingText(
        stream: stream,
        options: options,
        cancellationToken: cancellationToken,
      );
      developer.Timeline.finishSync();
    } catch (e) {
      developer.Timeline.finishSync();
      rethrow;
    }
  }

  Map<String, Object?> _buildArguments(SpeechToTextOptions? options) => {
    if (system != null) OpenTelemetryConsts.systemKey: system,
    OpenTelemetryConsts.requestModelKey:
        options?.modelId ?? modelId ?? 'unknown',
  };
}
