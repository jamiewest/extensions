import '../abstractions/chat_completion/chat_role.dart';
import '../abstractions/contents/text_content.dart';
import '../abstractions/image/delegating_image_generator.dart';
import '../abstractions/image/image_generation_options.dart';
import '../abstractions/image/image_generation_request.dart';
import '../abstractions/image/image_generation_response.dart';
import '../abstractions/image/image_generator.dart';
import '../abstractions/image/image_generator_metadata.dart';
import '../common/open_telemetry_log.dart';
import '../common/otel_message_serializer.dart';
import '../common/otel_metric_helpers.dart';
import '../open_telemetry_consts.dart';

/// Represents a delegating image generator that implements the OpenTelemetry
/// Semantic Conventions for Generative AI systems.
///
/// Remarks: This class provides an implementation of the Semantic Conventions
/// for Generative AI systems v1.41, defined at . The specification is still
/// experimental and subject to change; as such, the telemetry output by this
/// client is also subject to change.
class OpenTelemetryImageGenerator extends DelegatingImageGenerator {
  /// Initializes a new instance of the [OpenTelemetryImageGenerator] class.
  ///
  /// [innerGenerator] The underlying [ImageGenerator].
  ///
  /// [logger] The [Logger] to use for emitting any logging data from the
  /// client.
  ///
  /// [sourceName] An optional source name that will be used on the telemetry
  /// data.
  OpenTelemetryImageGenerator(
    ImageGenerator innerGenerator,
    {Logger? logger = null, String? sourceName = null, },
  ) :
      _logger = logger,
      _activitySource = new(name),
      _meter = new(name),
      _tokenUsageHistogram = OtelMetricHelpers.createGenAITokenUsageHistogram(_meter),
      _operationDurationHistogram = OtelMetricHelpers.createGenAIOperationDurationHistogram(_meter) {
    Debug.assertValue(innerGenerator != null, "Should have been validated by the base ctor");
    if (innerGenerator!.getService<ImageGeneratorMetadata>() is ImageGeneratorMetadata) {
      final metadata = innerGenerator!.getService<ImageGeneratorMetadata>() as ImageGeneratorMetadata;
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

  final Logger? _logger;

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
  Future<ImageGenerationResponse> generate(
    ImageGenerationRequest request,
    {ImageGenerationOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    _ = Throw.ifNull(request);
    var activity = createAndConfigureActivity(request, options);
    var stopwatch = _operationDurationHistogram.enabled ? Stopwatch.startNew() : null;
    var requestModelId = options?.modelId ?? _defaultModelId;
    var response = null;
    var error = null;
    try {
      response = await base.generateAsync(
        request,
        options,
        cancellationToken,
      ) .configureAwait(false);
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

  /// Creates an activity for an image generation request, or returns `null` if
  /// not enabled.
  Activity? createAndConfigureActivity(
    ImageGenerationRequest request,
    ImageGenerationOptions? options,
  ) {
    var activity = null;
    if (_activitySource.hasListeners()) {
      var modelId = options?.modelId ?? _defaultModelId;
      activity = _activitySource.startActivity(
                string.isNullOrWhiteSpace(modelId) ? OpenTelemetryConsts.genAI.generateContentName : '${OpenTelemetryConsts.genAI.generateContentName} ${modelId}',
                ActivityKind.client);
      if (activity is { IsAllDataRequested: true }) {
        _ = activity
                    .addTag(
                      OpenTelemetryConsts.genAI.operation.name,
                      OpenTelemetryConsts.genAI.generateContentName,
                    )
                    .addTag(OpenTelemetryConsts.genAI.output.type, OpenTelemetryConsts.typeImage)
                    .addTag(OpenTelemetryConsts.genAI.request.model, modelId)
                    .addTag(OpenTelemetryConsts.genAI.provider.name, _providerName);
        if (_serverAddress != null) {
          _ = activity
                        .addTag(OpenTelemetryConsts.server.address, _serverAddress)
                        .addTag(OpenTelemetryConsts.server.port, _serverPort);
        }
        if (options != null) {
          if (options.count is int) {
            final count = options.count as int;
            _ = activity.addTag(OpenTelemetryConsts.genAI.request.choiceCount, count);
          }
          if (options.imageSize is Size) {
            final size = options.imageSize as Size;
            _ = activity
                            .addTag("gen_ai.request.image.width", size.width)
                            .addTag("gen_ai.request.image.height", size.height);
          }
        }
        if (enableSensitiveData) {
          var content = [];
          if (request.prompt != null) {
            content.add(textContent(request.prompt));
          }
          if (request.originalImages != null) {
            content.addRange(request.originalImages);
          }
          _ = activity.addTag(
                        OpenTelemetryConsts.genAI.input.messages,
                        OtelMessageSerializer.serializeChatMessages([new(ChatRole.user, content)]));
          if (options?.additionalProperties is { } props) {
            for (final prop in props) {
              _ = activity.addTag(prop.key, prop.value);
            }
          }
        }
      }
    }
    return activity;
  }

  /// Adds image generation response information to the activity.
  void traceResponse(
    Activity? activity,
    String? requestModelId,
    ImageGenerationResponse? response,
    Exception? error,
    Stopwatch? stopwatch,
  ) {
    if (_operationDurationHistogram.enabled && stopwatch != null) {
      var tags = default;
      addMetricTags(ref tags, requestModelId);
      if (error != null) {
        tags.add(OpenTelemetryConsts.error.type, error.getType().fullName);
      }
      _operationDurationHistogram.record(stopwatch.elapsed.totalSeconds, tags);
    }
    OpenTelemetryLog.recordOperationError(activity, _logger, error);
    if (response != null) {
      if (enableSensitiveData &&
                response.contents is { Count: > 0 } contents &&
                activity is { IsAllDataRequested: true }) {
        _ = activity.addTag(
                    OpenTelemetryConsts.genAI.output.messages,
                    OtelMessageSerializer.serializeChatMessages([new(ChatRole.assistant, contents)]));
      }
      if (response.usage is { } usage) {
        if (_tokenUsageHistogram.enabled) {
          if (usage.inputTokenCount is long) {
            final inputTokens = usage.inputTokenCount as long;
            var tags = default;
            tags.add(OpenTelemetryConsts.genAI.token.type, OpenTelemetryConsts.tokenTypeInput);
            addMetricTags(ref tags, requestModelId);
            _tokenUsageHistogram.record((int)inputTokens, tags);
          }
          if (usage.outputTokenCount is long) {
            final outputTokens = usage.outputTokenCount as long;
            var tags = default;
            tags.add(OpenTelemetryConsts.genAI.token.type, OpenTelemetryConsts.tokenTypeOutput);
            addMetricTags(ref tags, requestModelId);
            _tokenUsageHistogram.record((int)outputTokens, tags);
          }
        }
        if (activity is { IsAllDataRequested: true }) {
          if (usage.inputTokenCount is long) {
            final inputTokens = usage.inputTokenCount as long;
            _ = activity.addTag(OpenTelemetryConsts.genAI.usage.inputTokens, (int)inputTokens);
          }
          if (usage.outputTokenCount is long) {
            final outputTokens = usage.outputTokenCount as long;
            _ = activity.addTag(OpenTelemetryConsts.genAI.usage.outputTokens, (int)outputTokens);
          }
        }
      }
    }
    /* TODO: unsupported node kind "unknown" */
    // void AddMetricTags(ref TagList tags, string? requestModelId)
    //         {
      //             tags.Add(OpenTelemetryConsts.GenAI.Operation.Name, OpenTelemetryConsts.GenAI.GenerateContentName);
      //
      //             if (requestModelId is not null)
      //             {
        //                 tags.Add(OpenTelemetryConsts.GenAI.Request.Model, requestModelId);
        //             }
      //
      //             tags.Add(OpenTelemetryConsts.GenAI.Provider.Name, _providerName);
      //
      //             if (_serverAddress is string endpointAddress)
      //             {
        //                 tags.Add(OpenTelemetryConsts.Server.Address, endpointAddress);
        //                 tags.Add(OpenTelemetryConsts.Server.Port, _serverPort);
        //             }
      //         }
  }
}
