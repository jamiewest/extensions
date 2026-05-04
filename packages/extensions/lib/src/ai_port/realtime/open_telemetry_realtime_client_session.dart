import '../abstractions/chat_completion/chat_client_metadata.dart';
import '../abstractions/contents/data_content.dart';
import '../abstractions/contents/error_content.dart';
import '../abstractions/contents/function_call_content.dart';
import '../abstractions/contents/function_result_content.dart';
import '../abstractions/contents/hosted_file_content.dart';
import '../abstractions/contents/hosted_vector_store_content.dart';
import '../abstractions/contents/mcp_server_tool_call_content.dart';
import '../abstractions/contents/mcp_server_tool_result_content.dart';
import '../abstractions/contents/text_content.dart';
import '../abstractions/contents/text_reasoning_content.dart';
import '../abstractions/contents/uri_content.dart';
import '../abstractions/realtime/create_conversation_item_realtime_client_message.dart';
import '../abstractions/realtime/create_response_realtime_client_message.dart';
import '../abstractions/realtime/error_realtime_server_message.dart';
import '../abstractions/realtime/input_audio_buffer_append_realtime_client_message.dart';
import '../abstractions/realtime/input_audio_buffer_commit_realtime_client_message.dart';
import '../abstractions/realtime/input_audio_transcription_realtime_server_message.dart';
import '../abstractions/realtime/output_text_audio_realtime_server_message.dart';
import '../abstractions/realtime/realtime_client_message.dart';
import '../abstractions/realtime/realtime_client_session.dart';
import '../abstractions/realtime/realtime_conversation_item.dart';
import '../abstractions/realtime/realtime_server_message.dart';
import '../abstractions/realtime/realtime_server_message_type.dart';
import '../abstractions/realtime/realtime_session_options.dart';
import '../abstractions/realtime/response_created_realtime_server_message.dart';
import '../abstractions/realtime/response_output_item_realtime_server_message.dart';
import '../common/open_telemetry_log.dart';
import '../common/otel_context.dart';
import '../common/otel_message_parts.dart';
import '../common/otel_metric_helpers.dart';
import '../open_telemetry_consts.dart';

/// Represents a delegating realtime session that follows the OpenTelemetry
/// Semantic Conventions for Generative AI systems where applicable.
///
/// Remarks: This class follows the patterns of the Semantic Conventions for
/// Generative AI systems v1.41 where applicable, as defined at , with custom
/// extensions for realtime-specific behavior. The specification does not
/// currently define a realtime operation; a custom operation name is used.
/// The specification is still experimental and subject to change; as such,
/// the telemetry output by this session is also subject to change. The
/// following standard OpenTelemetry GenAI conventions are supported:
/// `gen_ai.operation.name` - Operation name ("chat") `gen_ai.request.model` -
/// Model name from options `gen_ai.request.stream` - Indicates streaming
/// response requests; always `true` as realtime is inherently streaming
/// `gen_ai.provider.name` - Provider name from metadata `gen_ai.response.id`
/// - Response ID from ResponseDone messages `gen_ai.response.model` - Model
/// ID from response `gen_ai.response.time_to_first_chunk` - Time to first
/// streaming response chunk `gen_ai.usage.input_tokens` - Input token count
/// `gen_ai.usage.output_tokens` - Output token count
/// `gen_ai.usage.reasoning.output_tokens` - Reasoning output token count
/// `gen_ai.request.max_tokens` - Max output tokens from options
/// `gen_ai.system_instructions` - Instructions from options (sensitive data)
/// `gen_ai.conversation.id` - Conversation ID from response
/// `gen_ai.tool.definitions` - Tool definitions `gen_ai.input.messages` -
/// Input tool/MCP messages (sensitive data) `gen_ai.output.messages` - Output
/// tool/MCP messages (sensitive data) `server.address` / `server.port` -
/// Server endpoint info `error.type` - Error type on failures MCP (Model
/// Context Protocol) semantic conventions are supported for tool calls and
/// responses, including: MCP server tool calls and results MCP approval
/// requests and responses Function calls and results Additionally, the
/// following custom attributes are supported (not part of OpenTelemetry GenAI
/// semantic conventions as of v1.41): `gen_ai.request.tool_choice` - Tool
/// choice mode ("none", "auto", "required") or specific tool name
/// `gen_ai.realtime.voice` - Voice setting from options
/// `gen_ai.realtime.output_modalities` - Output modalities (text, audio)
/// `gen_ai.realtime.voice_speed` - Voice speed setting
/// `gen_ai.realtime.session_kind` - Session kind (Realtime/Transcription)
/// Metrics include: `gen_ai.client.operation.duration` - Duration histogram
/// `gen_ai.client.token.usage` - Token usage histogram
class OpenTelemetryRealtimeClientSession implements RealtimeClientSession {
  /// Initializes a new instance of the [OpenTelemetryRealtimeClientSession]
  /// class.
  ///
  /// [innerSession] The underlying [RealtimeClientSession].
  ///
  /// [logger] The [Logger] to use for emitting any logging data from the
  /// session.
  ///
  /// [sourceName] An optional source name that will be used on the telemetry
  /// data.
  OpenTelemetryRealtimeClientSession(
    RealtimeClientSession innerSession,
    {Logger? logger = null, String? sourceName = null, },
  ) :
      _innerSession = Throw.ifNull(innerSession),
      _logger = logger,
      _activitySource = new(name),
      _meter = new(name),
      _tokenUsageHistogram = OtelMetricHelpers.createGenAITokenUsageHistogram(_meter),
      _operationDurationHistogram = OtelMetricHelpers.createGenAIOperationDurationHistogram(_meter),
      _jsonSerializerOptions = AIJsonUtilities.defaultOptions {
    if (innerSession.getService(typeof(ChatClientMetadata)) is ChatClientMetadata) {
      final metadata = innerSession.getService(typeof(ChatClientMetadata)) as ChatClientMetadata;
      _defaultModelId = metadata.defaultModelId;
      _providerName = metadata.providerName;
      _serverAddress = metadata.providerUri?.host;
      _serverPort = metadata.providerUri?.port ?? 0;
    }
    var name = string.isNullOrEmpty(sourceName) ? OpenTelemetryConsts.defaultSourceName : sourceName!;
  }

  final ActivitySource _activitySource;

  final Meter _meter;

  final Histogram<int> _tokenUsageHistogram;

  final Histogram<double> _operationDurationHistogram;

  final String? _defaultModelId;

  final String? _providerName;

  final String? _serverAddress;

  final int _serverPort;

  final RealtimeClientSession _innerSession;

  final Logger? _logger;

  JsonSerializerOptions _jsonSerializerOptions;

  /// Gets or sets JSON serialization options to use when formatting realtime
  /// data into telemetry strings.
  JsonSerializerOptions jsonSerializerOptions;

  /// Gets or sets a value indicating whether potentially sensitive information
  /// should be included in telemetry.
  ///
  /// Remarks: By default, telemetry includes metadata, such as token counts,
  /// but not raw inputs and outputs, such as message content, function call
  /// arguments, and function call results. The default value can be overridden
  /// by setting the `OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT`
  /// environment variable to "true". Explicitly setting this property will
  /// override the environment variable.
  bool enableSensitiveData = TelemetryHelpers.EnableSensitiveDataDefault;

  RealtimeSessionOptions? get options {
    return _innerSession.options;
  }

  @override
  Future dispose() async  {
    _activitySource.dispose();
    _meter.dispose();
    await _innerSession.disposeAsync().configureAwait(false);
  }

  @override
  Object? getService(Type serviceType, {Object? serviceKey, }) {
    _ = Throw.ifNull(serviceType);
    return serviceType == typeof(ActivitySource) ? _activitySource :
            serviceKey == null && serviceType.isInstanceOfType(this) ? this :
            _innerSession.getService(serviceType, serviceKey);
  }

  @override
  Future send(RealtimeClientMessage message, {CancellationToken? cancellationToken, }) async  {
    if (enableSensitiveData && _activitySource.hasListeners()) {
      var otelMessage = extractClientOtelMessage(message);
      if (otelMessage != null) {
        var inputActivity = createAndConfigureActivity(options: null);
        if (inputActivity is { IsAllDataRequested: true }) {
          _ = inputActivity.addTag(
            OpenTelemetryConsts.genAI.input.messages,
            serializeMessage(otelMessage),
          );
        }
      }
    }
    await _innerSession.sendAsync(message, cancellationToken).configureAwait(false);
  }

  @override
  Stream<RealtimeServerMessage> getStreamingResponse({CancellationToken? cancellationToken}) async  {
    _jsonSerializerOptions.makeReadOnly();
    var options = options;
    var requestModelId = options?.model ?? _defaultModelId;
    var trackStreamingResponseTime = _activitySource.hasListeners();
    var stopwatch = _operationDurationHistogram.enabled || trackStreamingResponseTime ? Stopwatch.startNew() : null;
    var timeToFirstChunk = null;
    var captureMessages = enableSensitiveData && _activitySource.hasListeners();
    Stream<RealtimeServerMessage> responses;
    try {
      responses = _innerSession.getStreamingResponseAsync(cancellationToken);
    } catch (e, s) {
      if (e is Exception) {
        final ex = e as Exception;
        {
          var errorActivity = createAndConfigureActivity(options, streamingResponse: true);
          traceStreamingResponse(
            errorActivity,
            requestModelId,
            response: null,
            ex,
            stopwatch,
            timeToFirstChunk,
          );
          rethrow;
        }
      } else {
        rethrow;
      }
    }
    var responseEnumerator = responses.getAsyncEnumerator(cancellationToken);
    var error = null;
    var outputMessages = captureMessages ? [] : null;
    var outputModalities = _activitySource.hasListeners() ? [] : null;
    try {
      while (true) {
        RealtimeServerMessage message;
        try {
          if (!await responseEnumerator.moveNextAsync().configureAwait(false)) {
            break;
          }
          message = responseEnumerator.current;
        } catch (e, s) {
          if (e is Exception) {
            final ex = e as Exception;
            {
              error = ex;
              rethrow;
            }
          } else {
            rethrow;
          }
        }
        if (timeToFirstChunk == null && stopwatch != null) {
          timeToFirstChunk = stopwatch.elapsed.totalSeconds;
        }
        if (outputModalities != null) {
          var modality = getOutputModality(message);
          if (modality != null) {
            _ = outputModalities.add(modality);
          }
        }
        if (outputMessages != null) {
          var otelMessage = extractServerOtelMessage(message);
          if (otelMessage != null) {
            outputMessages.add(otelMessage);
          }
        }
        if (message is ResponseCreatedRealtimeServerMessage responseDoneMsg &&
                    responseDoneMsg.type == RealtimeServerMessageType.responseDone) {
          var responseActivity = createAndConfigureActivity(options, streamingResponse: true);
          // Add output modalities and messages tags
                    addOutputModalitiesTag(responseActivity, outputModalities);
          addOutputMessagesTag(responseActivity, outputMessages);
          traceStreamingResponse(
            responseActivity,
            requestModelId,
            responseDoneMsg,
            error,
            stopwatch,
            timeToFirstChunk,
          );
        }
        yield message;
      }
    } finally {
      if (error != null) {
        var errorActivity = createAndConfigureActivity(options, streamingResponse: true);
        addOutputModalitiesTag(errorActivity, outputModalities);
        addOutputMessagesTag(errorActivity, outputMessages);
        traceStreamingResponse(
          errorActivity,
          requestModelId,
          response: null,
          error,
          stopwatch,
          timeToFirstChunk,
        );
      }
      await responseEnumerator.disposeAsync().configureAwait(false);
    }
  }

  /// Adds output modalities tag to the activity.
  static void addOutputModalitiesTag(Activity? activity, Set<String>? outputModalities, ) {
    if (activity is { IsAllDataRequested: true } && outputModalities is { Count: > 0 }) {
      _ = activity.addTag(
        OpenTelemetryConsts.genAI.realtime.receivedModalities,
        $"[{string.join(", ", outputModalities.select((m) => '\"${m}\"'))}]",
      );
    }
  }

  /// Adds output messages tag to the activity if there are messages to add.
  static void addOutputMessagesTag(
    Activity? activity,
    List<RealtimeOtelMessage>? outputMessages,
  ) {
    if (activity is { IsAllDataRequested: true } && outputMessages is { Count: > 0 }) {
      _ = activity.addTag(
        OpenTelemetryConsts.genAI.output.messages,
        serializeMessages(outputMessages),
      );
    }
  }

  /// Gets the output modality from a server message, if applicable.
  static String? getOutputModality(RealtimeServerMessage message) {
    if (message is OutputTextAudioRealtimeServerMessage) {
      final textAudio = message as OutputTextAudioRealtimeServerMessage;
      if (textAudio.type == RealtimeServerMessageType.outputTextDelta || textAudio.type == RealtimeServerMessageType.outputTextDone) {
        return "text";
      }
      if (textAudio.type == RealtimeServerMessageType.outputAudioDelta || textAudio.type == RealtimeServerMessageType.outputAudioDone) {
        return "audio";
      }
      if (textAudio.type == RealtimeServerMessageType.outputAudioTranscriptionDelta || textAudio.type == RealtimeServerMessageType.outputAudioTranscriptionDone) {
        return "transcription";
      }
    }
    if (message is ResponseOutputItemRealtimeServerMessage) {
      return "item";
    }
    return null;
  }

  /// Extracts an OTel message from a realtime client message.
  RealtimeOtelMessage? extractClientOtelMessage(RealtimeClientMessage message) {
    switch (message) {
      case CreateConversationItemRealtimeClientMessage createMsg:
      return extractOtelMessage(createMsg.item);
      case InputAudioBufferAppendRealtimeClientMessage audioAppendMsg:
      var audioMessage = realtimeOtelMessage();
      audioMessage.parts.add(otelBlobPart());
      return audioMessage;
      case InputAudioBufferCommitRealtimeClientMessage:
      return realtimeOtelMessage() },
                };
  case CreateResponseRealtimeClientMessage responseCreateMsg:
    var responseMessage = realtimeOtelMessage();
    if (!string.isNullOrWhiteSpace(responseCreateMsg.instructions)) {
      responseMessage.parts.add(otelGenericPart());
  }

    if (responseCreateMsg.items is { Count: > 0 } items) {
      for (final item in items) {
        var itemMessage = extractOtelMessage(item);
        if (itemMessage != null) {
          for (final part in itemMessage.parts) {
            responseMessage.parts.add(part);
        }
      }
    }
  }

    return responseMessage.parts.count > 0 ? responseMessage : null;
  default:
    return null;
}
 }
/// Extracts an OTel message from a realtime server message.
RealtimeOtelMessage? extractServerOtelMessage(RealtimeServerMessage message) {
switch (message) {
  case ResponseOutputItemRealtimeServerMessage outputItemMsg:
    return extractOtelMessage(outputItemMsg.item);
  case OutputTextAudioRealtimeServerMessage textAudioMsg:
    String partType;
    String? content;
    if (textAudioMsg.type == RealtimeServerMessageType.outputAudioDelta || textAudioMsg.type == RealtimeServerMessageType.outputAudioDone) {
      partType = "audio";
      content = string.isNullOrEmpty(textAudioMsg.audio) ? "[audio data]" : textAudioMsg.audio;
    } else if (textAudioMsg.type == RealtimeServerMessageType.outputAudioTranscriptionDelta || textAudioMsg.type == RealtimeServerMessageType.outputAudioTranscriptionDone) {
      partType = "output_transcription";
      content = textAudioMsg.text;
    } else {
      partType = "text";
      content = textAudioMsg.text;
    }
    if (string.isNullOrEmpty(content)) {
      return null;
    }
    var textAudioOtelMessage = realtimeOtelMessage();
    textAudioOtelMessage.parts.add(otelGenericPart());
    return textAudioOtelMessage;
  case InputAudioTranscriptionRealtimeServerMessage transcriptionMsg:
    var transcriptionOtelMessage = realtimeOtelMessage();
    transcriptionOtelMessage.parts.add(otelGenericPart());
    return transcriptionOtelMessage;
  case ErrorRealtimeServerMessage errorMsg:
    var errorOtelMessage = realtimeOtelMessage();
    errorOtelMessage.parts.add(otelGenericPart());
    return errorOtelMessage;
  case ResponseCreatedRealtimeServerMessage responseCreatedMsg:
    if (responseCreatedMsg.type == RealtimeServerMessageType.responseCreated) {
      var responseOtelMessage = realtimeOtelMessage();
      for (final item in responseCreatedMsg.items) {
        var itemMessage = extractOtelMessage(item);
        if (itemMessage != null) {
          for (final part in itemMessage.parts) {
            responseOtelMessage.parts.add(part);
          }
        }
      }
      return responseOtelMessage.parts.count > 0 ? responseOtelMessage : null;
    }
    return null;
  default:
    return null;
}
 }
/// Serializes a single message to OTel format (as an array with one element).
static String serializeMessage(RealtimeOtelMessage message) {
return JsonSerializer.serialize([message], OtelContext.defaultValue.iEnumerableRealtimeOtelMessage);
 }
/// Serializes content items to OTel format.
static String serializeMessages(Iterable<RealtimeOtelMessage> messages) {
return JsonSerializer.serialize(messages, OtelContext.defaultValue.iEnumerableRealtimeOtelMessage);
 }
/// Extracts content from an AIContent list and converts to OTel format.
RealtimeOtelMessage? extractOtelMessage(RealtimeConversationItem? item) {
if (item?.contents == null or { Count: 0 }) {
  return null;
}
var message = realtimeOtelMessage();
for (final content in item.contents) {
  switch (content) {
    case TextContent tc:
      message.parts.add(otelGenericPart());
    case TextReasoningContent trc:
      message.parts.add(otelGenericPart());
    case FunctionCallContent fcc:
      message.parts.add(realtimeOtelToolCallPart());
    case FunctionResultContent frc:
      message.parts.add(otelToolCallResponsePart());
    case DataContent dc:
      message.parts.add(otelBlobPart());
    case UriContent uc:
      message.parts.add(otelUriPart());
    case HostedFileContent fc:
      message.parts.add(otelFilePart());
    case HostedVectorStoreContent vsc:
      message.parts.add(otelGenericPart());
    case ErrorContent ec:
      message.parts.add(otelGenericPart());
    case McpServerToolCallContent mstcc:
      message.parts.add(OtelServerToolCallPart<OtelMcpToolCall>(),
                    });
    case McpServerToolResultContent mstrc:
      message.parts.add(OtelServerToolCallResponsePart<OtelMcpToolCallResponse>(),
                    });
    default:
      var element = default;
      try {
        var unknownContentTypeInfo = null;
        JsonTypeInfo? ctsi;
        if (_jsonSerializerOptions?.tryGetTypeInfo(content.getType()) ?? false) {
          unknownContentTypeInfo = ctsi;
        } else {
          JsonTypeInfo? dtsi;
          if (AIJsonUtilities.defaultOptions.tryGetTypeInfo(content.getType())) {
            unknownContentTypeInfo = dtsi;
          }
        }
        if (unknownContentTypeInfo != null) {
          element = JsonSerializer.serializeToElement(content, unknownContentTypeInfo);
        }
      } catch (e, s) {
        {}
      }
      if (element.valueKind != JsonValueKind.undefined) {
        message.parts.add(otelGenericPart());
      }
  }
}
return message.parts.count > 0 ? message : null;
 }
/// Creates an activity for a realtime session request, or returns `null` if
/// not enabled.
Activity? createAndConfigureActivity(RealtimeSessionOptions? options, {bool? streamingResponse, }) {
var activity = null;
if (_activitySource.hasListeners()) {
  var modelId = options?.model ?? _defaultModelId;
  activity = _activitySource.startActivity(
                string.isNullOrWhiteSpace(modelId) ? OpenTelemetryConsts.genAI.realtimeName : '${OpenTelemetryConsts.genAI.realtimeName} ${modelId}',
                ActivityKind.client);
  if (activity is { IsAllDataRequested: true }) {
    _ = activity
                    .addTag(
                      OpenTelemetryConsts.genAI.operation.name,
                      OpenTelemetryConsts.genAI.chatName,
                    )
                    .addTag(OpenTelemetryConsts.genAI.request.model, modelId)
                    .addTag(OpenTelemetryConsts.genAI.provider.name, _providerName);
    if (streamingResponse) {
      _ = activity.addTag(OpenTelemetryConsts.genAI.request.stream, true);
    }
    if (_serverAddress != null) {
      _ = activity
                        .addTag(OpenTelemetryConsts.server.address, _serverAddress)
                        .addTag(OpenTelemetryConsts.server.port, _serverPort);
    }
    if (options != null) {
      if (options.maxOutputTokens is int) {
          final maxTokens = options.maxOutputTokens as int;
          _ = activity.addTag(OpenTelemetryConsts.genAI.request.maxTokens, maxTokens);
        }
      // Realtime-specific attributes
                    _ = activity.addTag(
                      OpenTelemetryConsts.genAI.realtime.sessionKind,
                      options.sessionKind.toString(),
                    );
      if (!string.isNullOrEmpty(options.voice)) {
        _ = activity.addTag(OpenTelemetryConsts.genAI.realtime.voice, options.voice);
      }
      if (options.outputModalities is { Count: > 0 } modalities) {
        _ = activity.addTag(
          OpenTelemetryConsts.genAI.realtime.outputModalities,
          $"[{string.join(", ", modalities.select((m) => '\"${m}\"'))}]",
        );
      }
      if (enableSensitiveData) {
        if (!string.isNullOrWhiteSpace(options.instructions)) {
          _ = activity.addTag(
                                OpenTelemetryConsts.genAI.systemInstructions,
                                JsonSerializer.serialize(
                                  List.filled(1, null) { otelGenericPart() },
                                  OtelContext.defaultValue.iListObject,
                                ) );
        }
      }
      if (options.tools is { Count: > 0 }) {
        _ = activity.addTag(
                            OpenTelemetryConsts.genAI.tool.definitions,
                            JsonSerializer.serialize(
                              options.tools.select((t) => OtelFunction.create(t, includeOptionalProperties: enableSensitiveData)),
                              OtelContext.defaultValue.iEnumerableOtelFunction,
                            ) );
      }
    }
  }
}
return activity;
 }
/// Adds streaming response information to the activity.
void traceStreamingResponse(
  Activity? activity,
  String? requestModelId,
  ResponseCreatedRealtimeServerMessage? response,
  Exception? error,
  Stopwatch? stopwatch,
  {double? timeToFirstChunk, },
) {
if (_operationDurationHistogram.enabled && stopwatch != null) {
  var tags = default;
  addMetricTags(ref tags, requestModelId, responseModelId: null);
  if (error != null) {
    tags.add(OpenTelemetryConsts.error.type, error.getType().fullName);
  }

  _operationDurationHistogram.record(stopwatch.elapsed.totalSeconds, tags);
}
if (_tokenUsageHistogram.enabled && response?.usage is { } usage) {
  if (usage.inputTokenCount is long) {
      final inputTokens = usage.inputTokenCount as long;
      var tags = default;
      tags.add(OpenTelemetryConsts.genAI.token.type, OpenTelemetryConsts.tokenTypeInput);
      addMetricTags(ref tags, requestModelId, responseModelId: null);
      _tokenUsageHistogram.record((int)inputTokens, tags);
    }
  if (usage.outputTokenCount is long) {
      final outputTokens = usage.outputTokenCount as long;
      var tags = default;
      tags.add(OpenTelemetryConsts.genAI.token.type, OpenTelemetryConsts.tokenTypeOutput);
      addMetricTags(ref tags, requestModelId, responseModelId: null);
      _tokenUsageHistogram.record((int)outputTokens, tags);
    }
  if (usage.inputAudioTokenCount is long) {
      final inputAudioTokens = usage.inputAudioTokenCount as long;
      var tags = default;
      tags.add(OpenTelemetryConsts.genAI.token.type, OpenTelemetryConsts.tokenTypeInputAudio);
      addMetricTags(ref tags, requestModelId, responseModelId: null);
      _tokenUsageHistogram.record((int)inputAudioTokens, tags);
    }
  if (usage.inputTextTokenCount is long) {
      final inputTextTokens = usage.inputTextTokenCount as long;
      var tags = default;
      tags.add(OpenTelemetryConsts.genAI.token.type, OpenTelemetryConsts.tokenTypeInputText);
      addMetricTags(ref tags, requestModelId, responseModelId: null);
      _tokenUsageHistogram.record((int)inputTextTokens, tags);
    }
  if (usage.outputAudioTokenCount is long) {
      final outputAudioTokens = usage.outputAudioTokenCount as long;
      var tags = default;
      tags.add(OpenTelemetryConsts.genAI.token.type, OpenTelemetryConsts.tokenTypeOutputAudio);
      addMetricTags(ref tags, requestModelId, responseModelId: null);
      _tokenUsageHistogram.record((int)outputAudioTokens, tags);
    }
  if (usage.outputTextTokenCount is long) {
      final outputTextTokens = usage.outputTextTokenCount as long;
      var tags = default;
      tags.add(OpenTelemetryConsts.genAI.token.type, OpenTelemetryConsts.tokenTypeOutputText);
      addMetricTags(ref tags, requestModelId, responseModelId: null);
      _tokenUsageHistogram.record((int)outputTextTokens, tags);
    }
}
OpenTelemetryLog.recordOperationError(activity, _logger, error);
if (response != null&& activity != null) {
  if (enableSensitiveData && response.additionalProperties is { } metadata) {
    for (final prop in metadata) {
      _ = activity.addTag(prop.key, prop.value);
    }
  }

  if (!string.isNullOrWhiteSpace(response.responseId)) {
    _ = activity.addTag(OpenTelemetryConsts.genAI.response.id, response.responseId);
  }

  if (timeToFirstChunk is double) {
      final timeToFirstChunkValue = timeToFirstChunk as double;
      _ = activity.addTag(
        OpenTelemetryConsts.genAI.response.timeToFirstChunk,
        timeToFirstChunkValue,
      );
    }
  if (!string.isNullOrWhiteSpace(response.status)) {
    _ = activity.addTag(
      OpenTelemetryConsts.genAI.response.finishReasons,
      '[\"${response.status}\"]',
    );
  }

  if (response.usage is { } responseUsage) {
    if (responseUsage.inputTokenCount is long) {
        final inputTokens = responseUsage.inputTokenCount as long;
        _ = activity.addTag(OpenTelemetryConsts.genAI.usage.inputTokens, (int)inputTokens);
      }
    if (responseUsage.outputTokenCount is long) {
        final outputTokens = responseUsage.outputTokenCount as long;
        _ = activity.addTag(OpenTelemetryConsts.genAI.usage.outputTokens, (int)outputTokens);
      }
    if (responseUsage.cachedInputTokenCount is long) {
        final cachedInputTokens = responseUsage.cachedInputTokenCount as long;
        _ = activity.addTag(
          OpenTelemetryConsts.genAI.usage.cacheReadInputTokens,
          (int)cachedInputTokens,
        );
      }
    if (responseUsage.reasoningTokenCount is long) {
        final reasoningTokens = responseUsage.reasoningTokenCount as long;
        _ = activity.addTag(
          OpenTelemetryConsts.genAI.usage.reasoningOutputTokens,
          (int)reasoningTokens,
        );
      }
    if (responseUsage.inputAudioTokenCount is long) {
        final inputAudioTokens = responseUsage.inputAudioTokenCount as long;
        _ = activity.addTag(
          OpenTelemetryConsts.genAI.usage.inputAudioTokens,
          (int)inputAudioTokens,
        );
      }
    if (responseUsage.inputTextTokenCount is long) {
        final inputTextTokens = responseUsage.inputTextTokenCount as long;
        _ = activity.addTag(OpenTelemetryConsts.genAI.usage.inputTextTokens, (int)inputTextTokens);
      }
    if (responseUsage.outputAudioTokenCount is long) {
        final outputAudioTokens = responseUsage.outputAudioTokenCount as long;
        _ = activity.addTag(
          OpenTelemetryConsts.genAI.usage.outputAudioTokens,
          (int)outputAudioTokens,
        );
      }
    if (responseUsage.outputTextTokenCount is long) {
        final outputTextTokens = responseUsage.outputTextTokenCount as long;
        _ = activity.addTag(
          OpenTelemetryConsts.genAI.usage.outputTextTokens,
          (int)outputTextTokens,
        );
      }
  }

  if (response.error is { } responseError) {
    _ = activity.addTag(OpenTelemetryConsts.error.type, responseError.errorCode ?? "RealtimeError");
    _ = activity.setStatus(ActivityStatusCode.error, responseError.message);
  }
}
 }
void addMetricTags(TagList tags, String? requestModelId, String? responseModelId, ) {
tags.add(OpenTelemetryConsts.genAI.operation.name, OpenTelemetryConsts.genAI.chatName);
if (requestModelId != null) {
  tags.add(OpenTelemetryConsts.genAI.request.model, requestModelId);
}
tags.add(OpenTelemetryConsts.genAI.provider.name, _providerName);
if (_serverAddress is string) {
    final endpointAddress = _serverAddress as string;
    tags.add(OpenTelemetryConsts.server.address, endpointAddress);
    tags.add(OpenTelemetryConsts.server.port, _serverPort);
  }

if (responseModelId is string) {
    final responseModel = responseModelId as string;
    tags.add(OpenTelemetryConsts.genAI.response.model, responseModel);
  }
 }
 }
class RealtimeOtelMessage {
  RealtimeOtelMessage();

  String? role;

  List<Object> parts = [];

}
class RealtimeOtelToolCallPart {
  RealtimeOtelToolCallPart();

  String type = "tool_call";

  String? id;

  String? name;

  Map<String, Object?>? arguments;

}
