import 'package:extensions/annotations.dart';

/// Semantic convention constants for AI telemetry spans and attributes.
///
/// These values follow the OpenTelemetry Semantic Conventions for Generative
/// AI systems. Wire these up to an actual OpenTelemetry SDK when available.
@Source(
  name: 'OpenTelemetryConsts.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI/',
)
abstract final class OpenTelemetryConsts {
  // Span name templates
  static const String chatSpanName = 'gen_ai.chat';
  static const String embeddingsSpanName = 'gen_ai.embeddings';
  static const String imageGenerationSpanName = 'gen_ai.image_generation';
  static const String textToSpeechSpanName = 'gen_ai.text_to_speech';

  // Attribute keys
  static const String systemKey = 'gen_ai.system';
  static const String requestModelKey = 'gen_ai.request.model';
  static const String responseModelKey = 'gen_ai.response.model';
  static const String responseIdKey = 'gen_ai.response.id';
  static const String requestMaxTokensKey = 'gen_ai.request.max_tokens';
  static const String requestTemperatureKey = 'gen_ai.request.temperature';
  static const String requestTopPKey = 'gen_ai.request.top_p';
  static const String requestTopKKey = 'gen_ai.request.top_k';
  static const String inputTokensKey = 'gen_ai.usage.input_tokens';
  static const String outputTokensKey = 'gen_ai.usage.output_tokens';
  static const String finishReasonKey = 'gen_ai.response.finish_reasons';
  static const String errorTypeKey = 'error.type';
  static const String serverAddressKey = 'server.address';

  /// Histogram bucket boundaries for operation duration (seconds).
  static const List<double> operationDurationBuckets = [
    0.01,
    0.02,
    0.04,
    0.08,
    0.16,
    0.32,
    0.64,
    1.28,
    2.56,
    5.12,
    10.24,
    20.48,
    40.96,
    81.92,
  ];
}
