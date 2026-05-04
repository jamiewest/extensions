import '../../../../../lib/func_typedefs.dart';
import 'embedding_generator_builder.dart';
import 'open_telemetry_embedding_generator.dart';

/// Provides extensions for configuring [OpenTelemetryEmbeddingGenerator]
/// instances.
extension OpenTelemetryEmbeddingGeneratorBuilderExtensions on EmbeddingGeneratorBuilder<TInput, TEmbedding> {
  /// Adds OpenTelemetry support to the embedding generator pipeline, following
/// the OpenTelemetry Semantic Conventions for Generative AI systems.
///
/// Remarks: The draft specification this follows is available at . The
/// specification is still experimental and subject to change; as such, the
/// telemetry output by this generator is also subject to change.
///
/// Returns: The `builder`.
///
/// [builder] The [EmbeddingGeneratorBuilder].
///
/// [loggerFactory] An optional [LoggerFactory] to use to create a logger for
/// logging events.
///
/// [sourceName] An optional source name that will be used on the telemetry
/// data.
///
/// [configure] An optional callback that can be used to configure the
/// [OpenTelemetryEmbeddingGenerator] instance.
///
/// [TInput] The type of input used to produce embeddings.
///
/// [TEmbedding] The type of embedding generated.
EmbeddingGeneratorBuilder<TInput, TEmbedding> useOpenTelemetry<TEmbedding>({LoggerFactory? loggerFactory, String? sourceName, Action<OpenTelemetryEmbeddingGenerator<TInput, TEmbedding>>? configure, }) {
return Throw.ifNull(builder).use((innerGenerator, services) =>
        {
            loggerFactory ??= services.getService<LoggerFactory>();

            var generator = new OpenTelemetryEmbeddingGenerator<TInput, TEmbedding>(
                innerGenerator,
                loggerFactory?.createLogger(typeof(OpenTelemetryEmbeddingGenerator<TInput, TEmbedding>)),
                sourceName);
            configure?.invoke(generator);
            return generator;
        });
 }
 }
