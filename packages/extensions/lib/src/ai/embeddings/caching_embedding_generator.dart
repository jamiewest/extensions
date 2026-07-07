import 'dart:async';

import '../../system/threading/cancellation_token.dart';
import 'delegating_embedding_generator.dart';
import 'embedding.dart';
import 'embedding_generation_options.dart';
import 'generated_embeddings.dart';

/// An abstract [DelegatingEmbeddingGenerator] that caches embeddings for
/// individual input values.
///
/// Each input value is cached separately, so a request is forwarded to the
/// inner generator only for the values that are not already cached.
/// Subclasses provide the actual caching mechanism by implementing
/// [getCachedEmbedding] and [setCachedEmbedding].
abstract class CachingEmbeddingGenerator extends DelegatingEmbeddingGenerator {
  /// Creates a new [CachingEmbeddingGenerator].
  CachingEmbeddingGenerator(super.innerGenerator);

  /// Gets a cache key for a single input [value] and [options].
  ///
  /// Override to customize cache key generation.
  String getCacheKey(String value, EmbeddingGenerationOptions? options) {
    final buffer = StringBuffer()..write(value);
    if (options?.modelId != null) {
      buffer.write('|model:${options!.modelId}');
    }
    if (options?.dimensions != null) {
      buffer.write('|dimensions:${options!.dimensions}');
    }
    return buffer.toString();
  }

  /// Retrieves a cached embedding for the given key, or `null` if not
  /// found.
  Future<Embedding?> getCachedEmbedding(String key);

  /// Stores an embedding in the cache with the given key.
  Future<void> setCachedEmbedding(String key, Embedding embedding);

  @override
  Future<GeneratedEmbeddings> generateEmbeddings({
    required Iterable<String> values,
    EmbeddingGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    final inputs = values.toList();
    final keys = [for (final input in inputs) getCacheKey(input, options)];
    final results = List<Embedding?>.filled(inputs.length, null);
    final uncachedIndices = <int>[];

    for (var i = 0; i < inputs.length; i++) {
      final cached = await getCachedEmbedding(keys[i]);
      if (cached != null) {
        results[i] = cached;
      } else {
        uncachedIndices.add(i);
      }
    }

    final generated = GeneratedEmbeddings();
    if (uncachedIndices.isNotEmpty) {
      final freshValues =
          uncachedIndices.map((index) => inputs[index]).toList();
      final fresh = await super.generateEmbeddings(
        values: freshValues,
        options: options,
        cancellationToken: cancellationToken,
      );

      if (fresh.length != freshValues.length) {
        throw StateError(
          'The inner generator returned ${fresh.length} embeddings for '
          '${freshValues.length} values.',
        );
      }

      for (var i = 0; i < uncachedIndices.length; i++) {
        final index = uncachedIndices[i];
        results[index] = fresh[i];
        await setCachedEmbedding(keys[index], fresh[i]);
      }

      generated.usage = fresh.usage;
      generated.additionalProperties = fresh.additionalProperties;
    }

    for (final embedding in results) {
      if (embedding != null) {
        generated.add(embedding);
      }
    }
    return generated;
  }
}
