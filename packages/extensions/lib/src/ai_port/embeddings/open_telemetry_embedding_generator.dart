import '../abstractions/embeddings/delegating_embedding_generator.dart';
import '../abstractions/embeddings/embedding_generation_options.dart';
import '../abstractions/embeddings/embedding_generator_metadata.dart';
import '../abstractions/embeddings/generated_embeddings.dart';
import '../common/open_telemetry_log.dart';
import '../common/otel_metric_helpers.dart';
import '../open_telemetry_consts.dart';

/// Represents a delegating embedding generator that implements the
/// OpenTelemetry Semantic Conventions for Generative AI systems.
///
/// Remarks: This class provides an implementation of the Semantic Conventions
/// for Generative AI systems v1.41, defined at . The specification is still
/// experimental and subject to change; as such, the telemetry output by this
/// client is also subject to change.
///
/// [TInput] The type of input used to produce embeddings.
///
/// [TEmbedding] The type of embedding generated.
class OpenTelemetryEmbeddingGenerator<TInput,TEmbedding> extends DelegatingEmbeddingGenerator<TInput, TEmbedding> {
  /// Initializes a new instance of the [OpenTelemetryEmbeddingGenerator] class.
  ///
  /// [innerGenerator] The underlying [EmbeddingGenerator], which is the next
  /// stage of the pipeline.
  ///
  /// [logger] The [Logger] to use for emitting any logging data from the
  /// generator.
  ///
  /// [sourceName] An optional source name that will be used on the telemetry
  /// data.
  OpenTelemetryEmbeddingGenerator(
    EmbeddingGenerator<TInput, TEmbedding> innerGenerator,
    {Logger? logger = null, String? sourceName = null, },
  ) :
      _logger = logger,
      _activitySource = new(name),
      _meter = new(name),
      _tokenUsageHistogram = OtelMetricHelpers.createGenAITokenUsageHistogram(_meter),
      _operationDurationHistogram = OtelMetricHelpers.createGenAIOperationDurationHistogram(_meter) {
    Debug.assertValue(innerGenerator != null, "Should have been validated by the base ctor.");
    if (innerGenerator!.getService<EmbeddingGeneratorMetadata>() is EmbeddingGeneratorMetadata) {
      final metadata = innerGenerator!.getService<EmbeddingGeneratorMetadata>() as EmbeddingGeneratorMetadata;
      _defaultModelId = metadata.defaultModelId;
      _defaultModelDimensions = metadata.defaultModelDimensions;
      _providerName = metadata.providerName;
      _endpointAddress = metadata.providerUri?.host;
      _endpointPort = metadata.providerUri?.port ?? 0;
    }
    var name = string.isNullOrEmpty(sourceName) ? OpenTelemetryConsts.defaultSourceName : sourceName!;
  }

  final ActivitySource _activitySource;

  final Meter _meter;

  final Histogram<int> _tokenUsageHistogram;

  final Histogram<double> _operationDurationHistogram;

  final String? _providerName;

  final String? _defaultModelId;

  final int? _defaultModelDimensions;

  final String? _endpointAddress;

  final int _endpointPort;

  final Logger? _logger;

  /// Gets or sets a value indicating whether potentially sensitive information
  /// should be included in telemetry.
  ///
  /// Remarks: By default, telemetry includes metadata, such as token counts,
  /// but not raw inputs and outputs or additional options data. The default
  /// value can be overridden by setting the
  /// `OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT` environment variable
  /// to "true". Explicitly setting this property will override the environment
  /// variable.
  bool enableSensitiveData = TelemetryHelpers.EnableSensitiveDataDefault;

  @override
  Object? getService(Type serviceType, {Object? serviceKey, }) {
    return serviceType == typeof(ActivitySource) ? _activitySource :
        base.getService(serviceType, serviceKey);
  }

  @override
  Future<GeneratedEmbeddings<TEmbedding>> generate(
    Iterable<TInput> values,
    {EmbeddingGenerationOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    _ = Throw.ifNull(values);
    var activity = createAndConfigureActivity(options);
    var stopwatch = _operationDurationHistogram.enabled ? Stopwatch.startNew() : null;
    var requestModelId = options?.modelId ?? _defaultModelId;
    var response = null;
    var error = null;
    try {
      response = await base.generateAsync(values, options, cancellationToken);
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
    return response;
  }

  @override
  void dispose(bool disposing) {
    if (disposing) {
      _activitySource.dispose();
      _meter.dispose();
    }
    base.dispose(disposing);
  }

  /// Creates an activity for an embedding generation request, or returns `null`
  /// if not enabled.
  Activity? createAndConfigureActivity(EmbeddingGenerationOptions? options) {
    var activity = null;
    if (_activitySource.hasListeners()) {
      var modelId = options?.modelId ?? _defaultModelId;
      activity = _activitySource.startActivity(
                string.isNullOrWhiteSpace(modelId) ? OpenTelemetryConsts.genAI.embeddingsName : '${OpenTelemetryConsts.genAI.embeddingsName} ${modelId}',
                ActivityKind.client,
                default(ActivityContext),
                [
                    new(
                      OpenTelemetryConsts.genAI.operation.name,
                      OpenTelemetryConsts.genAI.embeddingsName,
                    ),
                    new(OpenTelemetryConsts.genAI.request.model, modelId),
                    new(OpenTelemetryConsts.genAI.provider.name, _providerName),
                ]);
      if (activity != null) {
        if (_endpointAddress != null) {
          _ = activity
                        .addTag(OpenTelemetryConsts.server.address, _endpointAddress)
                        .addTag(OpenTelemetryConsts.server.port, _endpointPort);
        }
        if ((options?.dimensions ?? _defaultModelDimensions) is int) {
          final dimensionsValue = (options?.dimensions ?? _defaultModelDimensions) as int;
          _ = activity.addTag(
            OpenTelemetryConsts.genAI.embeddings.dimension.count,
            dimensionsValue,
          );
        }
        if (enableSensitiveData && options?.additionalProperties is { } props) {
          for (final prop in props) {
            _ = activity.addTag(prop.key, prop.value);
          }
        }
      }
    }
    return activity;
  }

  /// Adds embedding generation response information to the activity.
  void traceResponse(
    Activity? activity,
    String? requestModelId,
    GeneratedEmbeddings<TEmbedding>? embeddings,
    Exception? error,
    Stopwatch? stopwatch,
  ) {
    var inputTokens = null;
    var responseModelId = null;
    if (embeddings != null) {
      responseModelId = embeddings.firstOrDefault()?.modelId;
      if (embeddings.usage?.inputTokenCount is long) {
        final i = embeddings.usage?.inputTokenCount as long;
        inputTokens = inputTokens.getValueOrDefault() + (int)i;
      }
    }
    if (_operationDurationHistogram.enabled && stopwatch != null) {
      var tags = default;
      addMetricTags(ref tags, requestModelId, responseModelId);
      if (error != null) {
        tags.add(OpenTelemetryConsts.error.type, error.getType().fullName);
      }
      _operationDurationHistogram.record(stopwatch.elapsed.totalSeconds, tags);
    }
    if (_tokenUsageHistogram.enabled && inputTokens.hasValue) {
      var tags = default;
      tags.add(OpenTelemetryConsts.genAI.token.type, OpenTelemetryConsts.tokenTypeInput);
      addMetricTags(ref tags, requestModelId, responseModelId);
      _tokenUsageHistogram.record(inputTokens.value, tags);
    }
    OpenTelemetryLog.recordOperationError(activity, _logger, error);
    if (activity != null) {
      if (inputTokens.hasValue) {
        _ = activity.addTag(OpenTelemetryConsts.genAI.usage.inputTokens, inputTokens);
      }
      if (responseModelId != null) {
        _ = activity.addTag(OpenTelemetryConsts.genAI.response.model, responseModelId);
      }
      if (enableSensitiveData && embeddings?.additionalProperties is { } props) {
        for (final prop in props) {
          _ = activity.addTag(prop.key, prop.value);
        }
      }
    }
  }

  void addMetricTags(TagList tags, String? requestModelId, String? responseModelId, ) {
    tags.add(OpenTelemetryConsts.genAI.operation.name, OpenTelemetryConsts.genAI.embeddingsName);
    if (requestModelId != null) {
      tags.add(OpenTelemetryConsts.genAI.request.model, requestModelId);
    }
    tags.add(OpenTelemetryConsts.genAI.provider.name, _providerName);
    if (_endpointAddress is string) {
      final endpointAddress = _endpointAddress as string;
      tags.add(OpenTelemetryConsts.server.address, endpointAddress);
      tags.add(OpenTelemetryConsts.server.port, _endpointPort);
    }
    if (responseModelId != null) {
      tags.add(OpenTelemetryConsts.genAI.response.model, responseModelId);
    }
  }
}
