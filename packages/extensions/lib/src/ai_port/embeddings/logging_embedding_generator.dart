import '../abstractions/embeddings/delegating_embedding_generator.dart';
import '../abstractions/embeddings/embedding_generation_options.dart';
import '../abstractions/embeddings/embedding_generator_metadata.dart';
import '../abstractions/embeddings/generated_embeddings.dart';

/// A delegating embedding generator that logs embedding generation operations
/// to an [Logger].
///
/// Remarks: The provided implementation of [EmbeddingGenerator] is
/// thread-safe for concurrent use so long as the [Logger] employed is also
/// thread-safe for concurrent use. When the employed [Logger] enables
/// [Trace], the contents of values and options are logged. These values and
/// options may contain sensitive application data. [Trace] is disabled by
/// default and should never be enabled in a production environment. Messages
/// and options are not logged at other logging levels.
///
/// [TInput] Specifies the type of the input passed to the generator.
///
/// [TEmbedding] Specifies the type of the embedding instance produced by the
/// generator.
class LoggingEmbeddingGenerator<TInput,TEmbedding> extends DelegatingEmbeddingGenerator<TInput, TEmbedding> {
  /// Initializes a new instance of the [LoggingEmbeddingGenerator] class.
  ///
  /// [innerGenerator] The underlying [EmbeddingGenerator].
  ///
  /// [logger] An [Logger] instance that will be used for all logging.
  LoggingEmbeddingGenerator(
    EmbeddingGenerator<TInput, TEmbedding> innerGenerator,
    Logger logger,
  ) :
      _logger = Throw.ifNull(logger),
      _jsonSerializerOptions = AIJsonUtilities.defaultOptions;

  /// An [Logger] instance used for all logging.
  final Logger _logger;

  /// The [JsonSerializerOptions] to use for serialization of state written to
  /// the logger.
  JsonSerializerOptions _jsonSerializerOptions;

  /// Gets or sets JSON serialization options to use when serializing logging
  /// data.
  JsonSerializerOptions jsonSerializerOptions;

  @override
  Future<GeneratedEmbeddings<TEmbedding>> generate(
    Iterable<TInput> values,
    {EmbeddingGenerationOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    if (_logger.isEnabled(LogLevel.debug)) {
      if (_logger.isEnabled(LogLevel.trace)) {
        logInvokedSensitive(
          asJson(values),
          asJson(options),
          asJson(this.getService<EmbeddingGeneratorMetadata>()),
        );
      } else {
        logInvoked();
      }
    }
    try {
      var embeddings = await base.generateAsync(values, options, cancellationToken);
      logCompleted(embeddings.count);
      return embeddings;
    } catch (e, s) {
      if (e is OperationCanceledException) {
        final  = e as OperationCanceledException;
        {
          logInvocationCanceled();
          rethrow;
        }
      } else   if (e is Exception) {
        final ex = e as Exception;
        {
          logInvocationFailed(ex);
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  String asJson<T>(T value) {
    return JsonSerializer.serialize(value, _jsonSerializerOptions.getTypeInfo(typeof(T)));
  }

  void logInvoked() {
    // TODO: implement LogInvoked
    // C#:
    throw UnimplementedError('LogInvoked not implemented');
  }

  void logInvokedSensitive(
    String values,
    String embeddingGenerationOptions,
    String embeddingGeneratorMetadata,
  ) {
    // TODO: implement LogInvokedSensitive
    // C#:
    throw UnimplementedError('LogInvokedSensitive not implemented');
  }

  void logCompleted(int embeddingsCount) {
    // TODO: implement LogCompleted
    // C#:
    throw UnimplementedError('LogCompleted not implemented');
  }

  void logInvocationCanceled() {
    // TODO: implement LogInvocationCanceled
    // C#:
    throw UnimplementedError('LogInvocationCanceled not implemented');
  }

  void logInvocationFailed(Exception error) {
    // TODO: implement LogInvocationFailed
    // C#:
    throw UnimplementedError('LogInvocationFailed not implemented');
  }
}
