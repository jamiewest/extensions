import 'dart:convert';

import 'package:extensions/annotations.dart';
import 'package:http/http.dart' as http;

import '../../system/threading/cancellation_token.dart';
import '../embeddings/embedding.dart';
import '../embeddings/embedding_generation_options.dart';
import '../embeddings/embedding_generator.dart';
import '../embeddings/embedding_generator_builder.dart';
import '../embeddings/embedding_generator_metadata.dart';
import '../embeddings/generated_embeddings.dart';
import '../usage_details.dart';
import 'open_ai_client_options.dart';

/// An [EmbeddingGenerator] for the OpenAI embeddings API.
///
/// Works with any OpenAI-compatible endpoint including LM Studio.
@Source(
  name: 'OpenAIEmbeddingGenerator.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.OpenAI/',
)
final class OpenAIEmbeddingGenerator implements EmbeddingGenerator {
  /// Creates a new [OpenAIEmbeddingGenerator].
  OpenAIEmbeddingGenerator(
    String modelId,
    String apiKey, {
    int? defaultModelDimensions,
    OpenAIClientOptions? options,
  })  : _modelId = modelId,
        _apiKey = apiKey,
        _options = options ?? OpenAIClientOptions() {
    if (defaultModelDimensions != null && defaultModelDimensions <= 0) {
      throw ArgumentError.value(
        defaultModelDimensions,
        'defaultModelDimensions',
        'Must be greater than zero.',
      );
    }
    _defaultModelDimensions = defaultModelDimensions;
    metadata = EmbeddingGeneratorMetadata(
      providerName: 'openai',
      providerUri: _options.endpoint,
      defaultModelId: modelId,
      defaultModelDimensions: defaultModelDimensions,
    );
  }

  final String _modelId;
  final String _apiKey;
  final OpenAIClientOptions _options;
  late final int? _defaultModelDimensions;

  /// Metadata describing this generator instance.
  late final EmbeddingGeneratorMetadata metadata;

  /// Creates an [EmbeddingGeneratorBuilder] wrapping this generator.
  EmbeddingGeneratorBuilder asBuilder() => EmbeddingGeneratorBuilder(this);

  @override
  Future<GeneratedEmbeddings> generateEmbeddings({
    required Iterable<String> values,
    EmbeddingGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    final effectiveModel = options?.modelId ?? _modelId;
    final body = <String, dynamic>{
      'model': effectiveModel,
      'input': values.toList(),
    };

    final dimensions = options?.dimensions ?? _defaultModelDimensions;
    if (dimensions != null) body['dimensions'] = dimensions;

    final client = _options.httpClient ?? http.Client();
    final owned = _options.httpClient == null;

    try {
      final response = await client.post(
        Uri.parse('${_options.endpoint}/embeddings'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw StateError(
          'OpenAI embeddings error ${response.statusCode}: ${response.body}',
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return _fromResponse(json, options);
    } finally {
      if (owned) client.close();
    }
  }

  @override
  T? getService<T>({Object? key}) {
    if (T == EmbeddingGeneratorMetadata) return metadata as T;
    if (T == OpenAIEmbeddingGenerator) return this as T;
    return null;
  }

  @override
  void dispose() {}

  GeneratedEmbeddings _fromResponse(
    Map<String, dynamic> json,
    EmbeddingGenerationOptions? options,
  ) {
    final data = json['data'] as List<dynamic>? ?? [];
    final usageMap = json['usage'] as Map<String, dynamic>?;
    final modelId = json['model'] as String?;

    final embeddings = GeneratedEmbeddings();
    embeddings.usage = usageMap != null
        ? UsageDetails(
            inputTokenCount: usageMap['prompt_tokens'] as int?,
            totalTokenCount: usageMap['total_tokens'] as int?,
          )
        : null;

    for (final item in data) {
      final d = item as Map<String, dynamic>;
      final raw = d['embedding'] as List<dynamic>;
      embeddings.add(Embedding(
        vector: raw.map((v) => (v as num).toDouble()).toList(),
        modelId: modelId,
      ));
    }

    return embeddings;
  }
}
