import '../abstractions/chat_completion/chat_client.dart';
import '../abstractions/chat_completion/chat_client_metadata.dart';
import '../abstractions/chat_completion/chat_message.dart';
import '../abstractions/chat_completion/chat_options.dart';
import '../abstractions/chat_completion/chat_response_format_json.dart';
import '../abstractions/chat_completion/chat_response_format_text.dart';
import '../abstractions/chat_completion/chat_response_update.dart';
import '../abstractions/chat_completion/delegating_chat_client.dart';
import '../common/open_telemetry_log.dart';
import '../common/otel_context.dart';
import '../common/otel_message_parts.dart';
import '../common/otel_message_serializer.dart';
import '../common/otel_metric_helpers.dart';
import '../open_telemetry_consts.dart';

/// Represents a delegating chat client that implements the OpenTelemetry
/// Semantic Conventions for Generative AI systems.
///
/// Remarks: This class provides an implementation of the Semantic Conventions
/// for Generative AI systems v1.41, defined at . The specification is still
/// experimental and subject to change; as such, the telemetry output by this
/// client is also subject to change.
class OpenTelemetryChatClient extends DelegatingChatClient {
  /// Initializes a new instance of the [OpenTelemetryChatClient] class.
  ///
  /// [innerClient] The underlying [ChatClient].
  ///
  /// [logger] The [Logger] to use for emitting any logging data from the
  /// client.
  ///
  /// [sourceName] An optional source name that will be used on the telemetry
  /// data.
  OpenTelemetryChatClient(
    ChatClient innerClient,
    {Logger? logger = null, String? sourceName = null, },
  ) :
      _logger = logger,
      _activitySource = new(name),
      _meter = new(name),
      _tokenUsageHistogram = OtelMetricHelpers.createGenAITokenUsageHistogram(_meter),
      _operationDurationHistogram = OtelMetricHelpers.createGenAIOperationDurationHistogram(_meter),
      _timeToFirstChunkHistogram = _meter.createHistogram<double>(
            OpenTelemetryConsts.genAI.client.timeToFirstChunk.name,
            OpenTelemetryConsts.secondsUnit,
            OpenTelemetryConsts.genAI.client.timeToFirstChunk.description,
            advice: new() { HistogramBucketBoundaries = OpenTelemetryConsts.genAI.client.timeToFirstChunk.explicitBucketBoundaries }
            ), _timePerOutputChunkHistogram = _meter.createHistogram<double>(
            OpenTelemetryConsts.genAI.client.timePerOutputChunk.name,
            OpenTelemetryConsts.secondsUnit,
            OpenTelemetryConsts.genAI.client.timePerOutputChunk.description,
            advice: new() { HistogramBucketBoundaries = OpenTelemetryConsts.genAI.client.timePerOutputChunk.explicitBucketBoundaries }
            ), _jsonSerializerOptions = AIJsonUtilities.defaultOptions {
    Debug.assertValue(innerClient != null, "Should have been validated by the base ctor");
    if (innerClient!.getService<ChatClientMetadata>() is ChatClientMetadata) {
      final metadata = innerClient!.getService<ChatClientMetadata>() as ChatClientMetadata;
      _defaultModelId = metadata.defaultModelId;
      _providerName = metadata.providerName;
      _serverAddress = metadata.providerUri?.host;
      _serverPort = metadata.providerUri?.port ?? 0;
    }
    var name = string.isNullOrEmpty(sourceName) ? OpenTelemetryConsts.defaultSourceName : sourceName!;
  }

  final ActivitySource _activitySource;

  final Meter _meter;

  final Logger? _logger;

  final Histogram<int> _tokenUsageHistogram;

  final Histogram<double> _operationDurationHistogram;

  final Histogram<double> _timeToFirstChunkHistogram;

  final Histogram<double> _timePerOutputChunkHistogram;

  final String? _defaultModelId;

  final String? _providerName;

  final String? _serverAddress;

  final int _serverPort;

  JsonSerializerOptions _jsonSerializerOptions;

  /// Gets or sets JSON serialization options to use when formatting chat data
  /// into telemetry strings.
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

  @override
  void dispose(bool disposing) {
    if (disposing) {
      _activitySource.dispose();
      _meter.dispose();
    }
    base.dispose(disposing);
  }

  @override
  Object? getService(Type serviceType, {Object? serviceKey, }) {
    return serviceType == typeof(ActivitySource) ? _activitySource :
        base.getService(serviceType, serviceKey);
  }

  @override
  Future<ChatResponse> getResponse(
    Iterable<ChatMessage> messages,
    {ChatOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    _ = Throw.ifNull(messages);
    _jsonSerializerOptions.makeReadOnly();
    var activity = createAndConfigureActivity(options);
    var stopwatch = _operationDurationHistogram.enabled ? Stopwatch.startNew() : null;
    var requestModelId = options?.modelId ?? _defaultModelId;
    addInputMessagesTags(messages, options, activity);
    var response = null;
    var error = null;
    try {
      response = await base.getResponseAsync(messages, options, cancellationToken);
      return response;
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
    } finally {
      traceResponse(activity, requestModelId, response, error, stopwatch);
    }
  }

  @override
  Stream<ChatResponseUpdate> getStreamingResponse(
    Iterable<ChatMessage> messages,
    {ChatOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    _ = Throw.ifNull(messages);
    _jsonSerializerOptions.makeReadOnly();
    var activity = createAndConfigureActivity(options, streaming: true);
    var recordChunkHistograms = _timeToFirstChunkHistogram.enabled || _timePerOutputChunkHistogram.enabled;
    var stopwatch = _operationDurationHistogram.enabled || recordChunkHistograms || activity != null ? Stopwatch.startNew() : null;
    var requestModelId = options?.modelId ?? _defaultModelId;
    addInputMessagesTags(messages, options, activity);
    Stream<ChatResponseUpdate> updates;
    try {
      updates = base.getStreamingResponseAsync(messages, options, cancellationToken);
    } catch (e, s) {
      if (e is Exception) {
        final ex = e as Exception;
        {
          traceResponse(activity, requestModelId, response: null, ex, stopwatch);
          rethrow;
        }
      } else {
        rethrow;
      }
    }
    var responseEnumerator = updates.getAsyncEnumerator(cancellationToken);
    var trackedUpdates = [];
    var lastChunkElapsed = default;
    var isFirstChunk = true;
    var responseModelSet = false;
    var timeToFirstChunk = null;
    var chunkMetricTags = default;
    if (recordChunkHistograms) {
      addMetricTags(ref chunkMetricTags, requestModelId, response: null);
    }
    var error = null;
    try {
      while (true) {
        ChatResponseUpdate update;
        try {
          if (!await responseEnumerator.moveNextAsync()) {
            break;
          }
          update = responseEnumerator.current;
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
        if (recordChunkHistograms) {
          Debug.assertValue(
            stopwatch != null,
            "stopwatch should have been initialized when recordChunkHistograms is true",
          );
          var currentElapsed = stopwatch!.elapsed;
          var delta = (currentElapsed - lastChunkElapsed).totalSeconds;
          if (!responseModelSet && update.modelId is string) {
            final modelId = !responseModelSet && update.modelId as string;
            chunkMetricTags.add(OpenTelemetryConsts.genAI.response.model, modelId);
            responseModelSet = true;
          }
          if (isFirstChunk) {
            isFirstChunk = false;
            timeToFirstChunk = delta;
            if (_timeToFirstChunkHistogram.enabled) {
              _timeToFirstChunkHistogram.record(delta, chunkMetricTags);
            }
          } else if (_timePerOutputChunkHistogram.enabled) {
            _timePerOutputChunkHistogram.record(delta, chunkMetricTags);
          }
          lastChunkElapsed = currentElapsed;
        } else if (activity != null && timeToFirstChunk == null) {
          Debug.assertValue(
            stopwatch != null,
            "stopwatch should have been initialized when activity != null",
          );
          timeToFirstChunk = stopwatch!.elapsed.totalSeconds;
        }
        trackedUpdates.add(update);
        yield update;
        if (activity != null) {
          Activity.current = activity;
        }
      }
    } finally {
      traceResponse(
        activity,
        requestModelId,
        trackedUpdates.toChatResponse(),
        error,
        stopwatch,
        timeToFirstChunk,
      );
      await responseEnumerator.disposeAsync();
    }
  }

  /// Creates an activity for a chat request, or returns `null` if not enabled.
  Activity? createAndConfigureActivity(ChatOptions? options, {bool? streaming, }) {
    var activity = null;
    if (_activitySource.hasListeners()) {
      var modelId = options?.modelId ?? _defaultModelId;
      activity = _activitySource.startActivity(
                string.isNullOrWhiteSpace(modelId) ? OpenTelemetryConsts.genAI.chatName : '${OpenTelemetryConsts.genAI.chatName} ${modelId}',
                ActivityKind.client);
      if (enableSensitiveData) {
        activity?.setCustomProperty(SensitiveDataEnabledCustomKey, SensitiveDataEnabledTrueValue);
      }
      if (activity is { IsAllDataRequested: true }) {
        _ = activity
                    .addTag(
                      OpenTelemetryConsts.genAI.operation.name,
                      OpenTelemetryConsts.genAI.chatName,
                    )
                    .addTag(OpenTelemetryConsts.genAI.request.model, modelId)
                    .addTag(OpenTelemetryConsts.genAI.provider.name, _providerName);
        if (streaming) {
          _ = activity.addTag(OpenTelemetryConsts.genAI.request.stream, true);
        }
        if (_serverAddress != null) {
          _ = activity
                        .addTag(OpenTelemetryConsts.server.address, _serverAddress)
                        .addTag(OpenTelemetryConsts.server.port, _serverPort);
        }
        if (options != null) {
          if (options.conversationId is string) {
            final conversationId = options.conversationId as string;
            _ = activity.addTag(OpenTelemetryConsts.genAI.conversation.id, conversationId);
          }
          if (options.frequencyPenalty is float) {
            final frequencyPenalty = options.frequencyPenalty as float;
            _ = activity.addTag(
              OpenTelemetryConsts.genAI.request.frequencyPenalty,
              frequencyPenalty,
            );
          }
          if (options.maxOutputTokens is int) {
            final maxTokens = options.maxOutputTokens as int;
            _ = activity.addTag(OpenTelemetryConsts.genAI.request.maxTokens, maxTokens);
          }
          if (options.presencePenalty is float) {
            final presencePenalty = options.presencePenalty as float;
            _ = activity.addTag(OpenTelemetryConsts.genAI.request.presencePenalty, presencePenalty);
          }
          if (options.seed is long) {
            final seed = options.seed as long;
            _ = activity.addTag(OpenTelemetryConsts.genAI.request.seed, seed);
          }
          if (options.stopSequences is IList<String> { Count: > 0 } stopSequences) {
            _ = activity.addTag(
              OpenTelemetryConsts.genAI.request.stopSequences,
              $"[{string.join(", ", stopSequences.select((s) => '\"${s}\"'))}]",
            );
          }
          if (options.temperature is float) {
            final temperature = options.temperature as float;
            _ = activity.addTag(OpenTelemetryConsts.genAI.request.temperature, temperature);
          }
          if (options.topK is int) {
            final topK = options.topK as int;
            _ = activity.addTag(OpenTelemetryConsts.genAI.request.topK, topK);
          }
          if (options.topP is float) {
            final top_p = options.topP as float;
            _ = activity.addTag(OpenTelemetryConsts.genAI.request.topP, top_p);
          }
          if (options.responseFormat != null) {
            switch (options.responseFormat) {
              case ChatResponseFormatText:
              _ = activity.addTag(
                OpenTelemetryConsts.genAI.output.type,
                OpenTelemetryConsts.typeText,
              );
              case ChatResponseFormatJson:
              _ = activity.addTag(
                OpenTelemetryConsts.genAI.output.type,
                OpenTelemetryConsts.typeJson,
              );
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
          if (enableSensitiveData) {
            if (options.additionalProperties is { } props) {
              for (final prop in props) {
                _ = activity.addTag(prop.key, prop.value);
              }
            }
          }
        }
      }
    }
    return activity;
  }

  /// Adds chat response information to the activity.
  void traceResponse(
    Activity? activity,
    String? requestModelId,
    ChatResponse? response,
    Exception? error,
    Stopwatch? stopwatch,
    {double? timeToFirstChunk, },
  ) {
    if (_operationDurationHistogram.enabled && stopwatch != null) {
      var tags = default;
      addMetricTags(ref tags, requestModelId, response);
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
        addMetricTags(ref tags, requestModelId, response);
        _tokenUsageHistogram.record((int)inputTokens, tags);
      }
      if (usage.outputTokenCount is long) {
        final outputTokens = usage.outputTokenCount as long;
        var tags = default;
        tags.add(OpenTelemetryConsts.genAI.token.type, OpenTelemetryConsts.tokenTypeOutput);
        addMetricTags(ref tags, requestModelId, response);
        _tokenUsageHistogram.record((int)outputTokens, tags);
      }
    }
    OpenTelemetryLog.recordOperationError(activity, _logger, error);
    if (response != null) {
      addOutputMessagesTags(response, activity);
      if (activity != null) {
        if (response.finishReason is ChatFinishReason) {
          final finishReason = response.finishReason as ChatFinishReason;
          #pragma warning disable CA1308 // Normalize strings to uppercase
                    _ = activity.addTag(
                      OpenTelemetryConsts.genAI.response.finishReasons,
                      '[\"${finishReason.value.toLowerInvariant()}\"]',
                    );
        }
        if (!string.isNullOrWhiteSpace(response.responseId)) {
          _ = activity.addTag(OpenTelemetryConsts.genAI.response.id, response.responseId);
        }
        if (response.modelId != null) {
          _ = activity.addTag(OpenTelemetryConsts.genAI.response.model, response.modelId);
        }
        if (timeToFirstChunk is double) {
          final timeToFirstChunkValue = timeToFirstChunk as double;
          _ = activity.addTag(
            OpenTelemetryConsts.genAI.response.timeToFirstChunk,
            timeToFirstChunkValue,
          );
        }
        if (response.usage?.inputTokenCount is long) {
          final inputTokens = response.usage?.inputTokenCount as long;
          _ = activity.addTag(OpenTelemetryConsts.genAI.usage.inputTokens, (int)inputTokens);
        }
        if (response.usage?.outputTokenCount is long) {
          final outputTokens = response.usage?.outputTokenCount as long;
          _ = activity.addTag(OpenTelemetryConsts.genAI.usage.outputTokens, (int)outputTokens);
        }
        if (response.usage?.cachedInputTokenCount is long) {
          final cachedInputTokens = response.usage?.cachedInputTokenCount as long;
          _ = activity.addTag(
            OpenTelemetryConsts.genAI.usage.cacheReadInputTokens,
            (int)cachedInputTokens,
          );
        }
        if (response.usage?.reasoningTokenCount is long) {
          final reasoningTokens = response.usage?.reasoningTokenCount as long;
          _ = activity.addTag(
            OpenTelemetryConsts.genAI.usage.reasoningOutputTokens,
            (int)reasoningTokens,
          );
        }
        if (enableSensitiveData && response.additionalProperties is { } props) {
          for (final prop in props) {
            _ = activity.addTag(prop.key, prop.value);
          }
        }
      }
    }
  }

  void addMetricTags(TagList tags, String? requestModelId, ChatResponse? response, ) {
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
    if (response?.modelId is string) {
      final responseModel = response?.modelId as string;
      tags.add(OpenTelemetryConsts.genAI.response.model, responseModel);
    }
  }

  void addInputMessagesTags(
    Iterable<ChatMessage> messages,
    ChatOptions? options,
    Activity? activity,
  ) {
    if (enableSensitiveData && activity is { IsAllDataRequested: true }) {
      if (!string.isNullOrWhiteSpace(options?.instructions)) {
        _ = activity.addTag(
                    OpenTelemetryConsts.genAI.systemInstructions,
                    JsonSerializer.serialize(
                      List.filled(1, null) { otelGenericPart() },
                      OtelMessageSerializer.defaultOptions.getTypeInfo(typeof(IList<Object>)),
                    ) );
      }
      _ = activity.addTag(
                OpenTelemetryConsts.genAI.input.messages,
                OtelMessageSerializer.serializeChatMessages(
                  messages,
                  customContentSerializerOptions: _jsonSerializerOptions,
                ) );
    }
  }

  void addOutputMessagesTags(ChatResponse response, Activity? activity, ) {
    if (enableSensitiveData && activity is { IsAllDataRequested: true }) {
      _ = activity.addTag(
                OpenTelemetryConsts.genAI.output.messages,
                OtelMessageSerializer.serializeChatMessages(
                  response.messages,
                  response.finishReason,
                  customContentSerializerOptions: _jsonSerializerOptions,
                ) );
    }
  }
}
class OtelCodeInterpreterToolCall {
  OtelCodeInterpreterToolCall();

  String type = "code_interpreter";

  String? code;

}
class OtelCodeInterpreterToolCallResponse {
  OtelCodeInterpreterToolCallResponse();

  String type = "code_interpreter";

  Object? output;

}
class OtelImageGenerationToolCall {
  OtelImageGenerationToolCall();

  String type = "image_generation";

}
class OtelImageGenerationToolCallResponse {
  OtelImageGenerationToolCallResponse();

  String type = "image_generation";

  Object? output;

}
class OtelMcpApprovalRequest {
  OtelMcpApprovalRequest();

  String type = "mcp_approval_request";

  String? serverName;

  Map<String, Object?>? arguments;

}
class OtelMcpApprovalResponse {
  OtelMcpApprovalResponse();

  String type = "mcp_approval_response";

  bool approved;

}
class OtelMessage {
  OtelMessage();

  String? role;

  String? name;

  List<Object> parts = [];

  String? finishReason;

}
class OtelToolCallRequestPart {
  OtelToolCallRequestPart();

  String type = "tool_call";

  String? id;

  String? name;

  Map<String, Object?>? arguments;

}
