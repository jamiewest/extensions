import '../abstractions/text_to_speech/delegating_text_to_speech_client.dart';
import '../abstractions/text_to_speech/text_to_speech_client.dart';
import '../abstractions/text_to_speech/text_to_speech_client_metadata.dart';
import '../abstractions/text_to_speech/text_to_speech_options.dart';
import '../abstractions/text_to_speech/text_to_speech_response.dart';
import '../abstractions/text_to_speech/text_to_speech_response_update.dart';
import '../common/open_telemetry_log.dart';
import '../common/otel_metric_helpers.dart';
import '../open_telemetry_consts.dart';

/// Represents a delegating text-to-speech client that implements the
/// OpenTelemetry Semantic Conventions for Generative AI systems.
///
/// Remarks: This class provides an implementation of the Semantic Conventions
/// for Generative AI systems v1.41, defined at . The specification is still
/// experimental and subject to change; as such, the telemetry output by this
/// client is also subject to change.
class OpenTelemetryTextToSpeechClient extends DelegatingTextToSpeechClient {
  /// Initializes a new instance of the [OpenTelemetryTextToSpeechClient] class.
  ///
  /// [innerClient] The underlying [TextToSpeechClient].
  ///
  /// [logger] The [Logger] to use for emitting any logging data from the
  /// client.
  ///
  /// [sourceName] An optional source name that will be used on the telemetry
  /// data.
  OpenTelemetryTextToSpeechClient(
    TextToSpeechClient innerClient,
    {Logger? logger = null, String? sourceName = null, },
  ) :
      _logger = logger,
      _activitySource = new(name),
      _meter = new(name),
      _tokenUsageHistogram = OtelMetricHelpers.createGenAITokenUsageHistogram(_meter),
      _operationDurationHistogram = OtelMetricHelpers.createGenAIOperationDurationHistogram(_meter) {
    Debug.assertValue(innerClient != null, "Should have been validated by the base ctor");
    if (innerClient!.getService<TextToSpeechClientMetadata>() is TextToSpeechClientMetadata) {
      final metadata = innerClient!.getService<TextToSpeechClientMetadata>() as TextToSpeechClientMetadata;
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
  Future<TextToSpeechResponse> getAudio(
    String text,
    {TextToSpeechOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    _ = Throw.ifNull(text);
    var activity = createAndConfigureActivity(options);
    var stopwatch = _operationDurationHistogram.enabled ? Stopwatch.startNew() : null;
    var requestModelId = options?.modelId ?? _defaultModelId;
    var response = null;
    var error = null;
    try {
      response = await base.getAudioAsync(text, options, cancellationToken);
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
  Stream<TextToSpeechResponseUpdate> getStreamingAudio(
    String text,
    {TextToSpeechOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    _ = Throw.ifNull(text);
    var activity = createAndConfigureActivity(options);
    var stopwatch = _operationDurationHistogram.enabled ? Stopwatch.startNew() : null;
    var requestModelId = options?.modelId ?? _defaultModelId;
    Stream<TextToSpeechResponseUpdate> updates;
    try {
      updates = base.getStreamingAudioAsync(text, options, cancellationToken);
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
    var error = null;
    try {
      while (true) {
        TextToSpeechResponseUpdate update;
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
        trackedUpdates.toTextToSpeechResponse(),
        error,
        stopwatch,
      );
      await responseEnumerator.disposeAsync();
    }
  }

  /// Creates an activity for a text-to-speech request, or returns `null` if not
  /// enabled.
  Activity? createAndConfigureActivity(TextToSpeechOptions? options) {
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
                    .addTag(OpenTelemetryConsts.genAI.request.model, modelId)
                    .addTag(OpenTelemetryConsts.genAI.provider.name, _providerName)
                    .addTag(OpenTelemetryConsts.genAI.output.type, OpenTelemetryConsts.typeAudio);
        if (_serverAddress != null) {
          _ = activity
                        .addTag(OpenTelemetryConsts.server.address, _serverAddress)
                        .addTag(OpenTelemetryConsts.server.port, _serverPort);
        }
        if (options != null) {
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

  /// Adds text-to-speech response information to the activity.
  void traceResponse(
    Activity? activity,
    String? requestModelId,
    TextToSpeechResponse? response,
    Exception? error,
    Stopwatch? stopwatch,
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
    if (response != null&& activity != null) {
      if (!string.isNullOrWhiteSpace(response.responseId)) {
        _ = activity.addTag(OpenTelemetryConsts.genAI.response.id, response.responseId);
      }
      if (response.modelId != null) {
        _ = activity.addTag(OpenTelemetryConsts.genAI.response.model, response.modelId);
      }
      if (response.usage?.inputTokenCount is long) {
        final inputTokens = response.usage?.inputTokenCount as long;
        _ = activity.addTag(OpenTelemetryConsts.genAI.usage.inputTokens, (int)inputTokens);
      }
      if (response.usage?.outputTokenCount is long) {
        final outputTokens = response.usage?.outputTokenCount as long;
        _ = activity.addTag(OpenTelemetryConsts.genAI.usage.outputTokens, (int)outputTokens);
      }
      if (enableSensitiveData && response.additionalProperties is { } props) {
        for (final prop in props) {
          _ = activity.addTag(prop.key, prop.value);
        }
      }
    }
    /* TODO: unsupported node kind "unknown" */
    // void AddMetricTags(ref TagList tags, string? requestModelId, TextToSpeechResponse? response)
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
      //
      //             if (response?.ModelId is string responseModel)
      //             {
        //                 tags.Add(OpenTelemetryConsts.GenAI.Response.Model, responseModel);
        //             }
      //         }
  }
}
