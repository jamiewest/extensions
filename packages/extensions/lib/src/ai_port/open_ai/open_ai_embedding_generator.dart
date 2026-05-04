import '../../../../../lib/func_typedefs.dart';
import '../abstractions/embeddings/embedding_generation_options.dart';
import '../abstractions/embeddings/embedding_generator_metadata.dart';
import '../abstractions/embeddings/generated_embeddings.dart';
import '../open_telemetry_consts.dart';
import 'open_ai_client_extensions.dart';
import 'open_ai_request_policies.dart';

/// An [EmbeddingGenerator] for an OpenAI [EmbeddingClient].
class OpenAEmbeddingGenerator implements EmbeddingGenerator<String, Embedding<double>> {
  /// Initializes a new instance of the [OpenAIEmbeddingGenerator] class.
  ///
  /// [embeddingClient] The underlying client.
  ///
  /// [defaultModelDimensions] The number of dimensions to generate in each
  /// embedding.
  OpenAEmbeddingGenerator(
    EmbeddingClient embeddingClient,
    {int? defaultModelDimensions = null, },
  ) :
      _embeddingClient = Throw.ifNull(embeddingClient),
      _dimensions = defaultModelDimensions {
    if (defaultModelDimensions < 1) {
      Throw.argumentOutOfRangeException(
        nameof(defaultModelDimensions),
        "Value must be greater than 0.",
      );
    }
    #pragma warning disable OPENAI001 // Endpoint and Model are experimental
        _metadata = new(
          "openai",
          embeddingClient.endpoint,
          _embeddingClient.model,
          defaultModelDimensions,
        );
  }

  static final Func4<EmbeddingClient, Iterable<String>, EmbeddingGenerationOptions, RequestOptions, Future<ClientResult<OpenAEmbeddingCollection>>>? _generateEmbeddingsAsync;

  /// Metadata about the embedding generator.
  final EmbeddingGeneratorMetadata _metadata;

  /// The underlying [ChatClient].
  final EmbeddingClient _embeddingClient;

  /// The number of dimensions produced by the generator.
  final int? _dimensions;

  /// Caller-registered policies applied to every [RequestOptions].
  final OpenARequestPolicies _requestPolicies;

  @override
  Future<GeneratedEmbeddings<Embedding<double>>> generate(
    Iterable<String> values,
    {EmbeddingGenerationOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    var openAIOptions = toOpenAIOptions(options);
    var t = _generateEmbeddingsAsync != null ?
            _generateEmbeddingsAsync(
              _embeddingClient,
              values,
              openAIOptions,
              cancellationToken.toRequestOptions(streaming: false, _requestPolicies),
            ) : 
            _embeddingClient.generateEmbeddingsAsync(values, openAIOptions, cancellationToken);
    var embeddings = (await t.configureAwait(false)).value;
    var usage = embeddings.usage != null ?
            new()
            {
                InputTokenCount = embeddings.usage.inputTokenCount,
                TotalTokenCount = embeddings.usage.totalTokenCount
            } :
            null;
    return new(embeddings.select((e) =>
                Embedding<double>(e.toFloats())
                {
                    CreatedAt = DateTimeOffset.utcNow,
                    ModelId = embeddings.model,
                }))
        {
            Usage = usage,
        };
  }

  void dispose() {

  }

  Object? getService(Type serviceType, Object? serviceKey, ) {
    _ = Throw.ifNull(serviceType);
    return serviceKey != null ? null :
            serviceType == typeof(EmbeddingGeneratorMetadata) ? _metadata :
            serviceType == typeof(EmbeddingClient) ? _embeddingClient :
            serviceType == typeof(OpenAIRequestPolicies) ? _requestPolicies :
            serviceType.isInstanceOfType(this) ? this :
            null;
  }

  /// Converts an extensions options instance to an OpenAI options instance.
  EmbeddingGenerationOptions toOpenAIOptions(EmbeddingGenerationOptions? options) {
    if (options?.rawRepresentationFactory?.invoke(this) is! EmbeddingGenerationOptions result) {
      result = new();
    }
    result.dimensions ??= options?.dimensions ?? _dimensions;
    #pragma warning disable SCME0001 // JsonPatch is experimental
        OpenAIClientExtensions.patchModelIfNotSet(ref result.patch, options?.modelId);
    return result;
  }
}
