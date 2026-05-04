import 'dart:developer' as developer;

import 'package:extensions/annotations.dart';

import '../../system/threading/cancellation_token.dart';
import '../open_telemetry_consts.dart';
import 'delegating_image_generator.dart';
import 'image_generator.dart';

/// A [DelegatingImageGenerator] that records OpenTelemetry spans.
@Source(
  name: 'OpenTelemetryImageGenerator.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI/ImageGeneration/',
)
class OpenTelemetryImageGenerator extends DelegatingImageGenerator {
  /// Creates a new [OpenTelemetryImageGenerator].
  OpenTelemetryImageGenerator(super.innerGenerator,
      {this.modelId, this.system});

  /// The model ID to record on spans.
  final String? modelId;

  /// The AI system name (e.g. `"openai"`).
  final String? system;

  @override
  Future<ImageGenerationResponse> generate({
    required ImageGenerationRequest request,
    ImageGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    developer.Timeline.startSync(
      OpenTelemetryConsts.imageGenerationSpanName,
      arguments: {
        if (system != null) OpenTelemetryConsts.systemKey: system,
        OpenTelemetryConsts.requestModelKey:
            options?.modelId ?? modelId ?? 'unknown',
      },
    );
    try {
      final result = await super.generate(
        request: request,
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
}
