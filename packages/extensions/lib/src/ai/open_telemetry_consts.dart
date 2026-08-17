/// Semantic convention constants for AI telemetry spans and attributes.
///
/// These values follow the OpenTelemetry Semantic Conventions for Generative
/// AI systems. Wire these up to an actual OpenTelemetry SDK when available.
abstract final class OpenTelemetryConsts {
  // Span name templates
  static const String chatSpanName = 'gen_ai.chat';
  static const String embeddingsSpanName = 'gen_ai.embeddings';
  static const String imageGenerationSpanName = 'gen_ai.image_generation';
  static const String textToSpeechSpanName = 'gen_ai.text_to_speech';
  static const String speechToTextSpanName = 'gen_ai.speech_to_text';
  static const String realtimeSpanName = 'gen_ai.realtime';
  static const String executeToolSpanName = 'execute_tool';
  static const String filesUploadSpanName = 'files.upload';
  static const String filesDownloadSpanName = 'files.download';
  static const String filesGetSpanName = 'files.get_info';
  static const String filesListSpanName = 'files.list';
  static const String filesDeleteSpanName = 'files.delete';

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
  static const String inputMessagesKey = 'gen_ai.input.messages';
  static const String outputMessagesKey = 'gen_ai.output.messages';
  static const String sessionKindKey = 'gen_ai.realtime.session_kind';
  static const String voiceKey = 'gen_ai.realtime.voice';
  static const String outputModalitiesKey = 'gen_ai.realtime.output_modalities';
  static const String filesOperationNameKey = 'files.operation.name';
  static const String filesIdKey = 'files.id';
  static const String filesMediaTypeKey = 'files.media_type';
  static const String fileNameKey = 'file.name';
  static const String operationNameKey = 'gen_ai.operation.name';
  static const String toolTypeKey = 'gen_ai.tool.type';
  static const String toolNameKey = 'gen_ai.tool.name';
  static const String toolDescriptionKey = 'gen_ai.tool.description';
  static const String toolCallIdKey = 'gen_ai.tool.call.id';
  static const String toolCallArgumentsKey = 'gen_ai.tool.call.arguments';
  static const String toolCallResultKey = 'gen_ai.tool.call.result';

  /// The `gen_ai.tool.type` value for function tools.
  static const String toolTypeFunction = 'function';

  /// Environment variable upstream reads to default `enableSensitiveData`.
  ///
  /// The Dart port does not read the environment (web support); hosts
  /// wire this value in explicitly during bootstrap.
  static const String genAICaptureMessageContentEnvVar =
      'OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT';

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
