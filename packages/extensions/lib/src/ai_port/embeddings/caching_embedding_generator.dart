import '../abstractions/embeddings/delegating_embedding_generator.dart';
import '../abstractions/embeddings/embedding_generation_options.dart';
import '../abstractions/embeddings/generated_embeddings.dart';

/// Represents a delegating embedding generator that caches the results of
/// embedding generation calls.
///
/// [TInput] The type from which embeddings will be generated.
///
/// [TEmbedding] The type of embeddings to generate.
abstract class CachingEmbeddingGenerator<TInput, TEmbedding>
    extends DelegatingEmbeddingGenerator<TInput, TEmbedding> {
  /// Initializes a new instance of the [CachingEmbeddingGenerator] class.
  ///
  /// [innerGenerator] The underlying [EmbeddingGenerator].
  const CachingEmbeddingGenerator(
    EmbeddingGenerator<TInput, TEmbedding> innerGenerator,
  );

  @override
  Future<GeneratedEmbeddings<TEmbedding>> generate(
    Iterable<TInput> values, {
    EmbeddingGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    _ = Throw.ifNull(values);
    if (values is ListTInput) {
      final valuesList = values as ListTInput;
      switch (valuesList.count) {
        case 0:
          return [];
        case 1:
          var cacheKey = getCacheKey(valuesList[0], options);
          if (await readCacheAsync(cacheKey, cancellationToken) is TEmbedding) {
            final e =
                await readCacheAsync(cacheKey, cancellationToken) as TEmbedding;
            return [e];
          } else {
            var generated = await base.generateAsync(
              valuesList,
              options,
              cancellationToken,
            );
            if (generated.count != 1) {
              Throw.invalidOperationException(
                'Expected exactly one embedding to be generated, but received ${generated.count}.',
              );
            }
            if (generated[0] == null) {
              Throw.invalidOperationException(
                "Generator produced null embedding.",
              );
            }
            await writeCacheAsync(cacheKey, generated[0], cancellationToken);
            return generated;
          }
      }
    }
    var results = [];
    var uncached = null;
    for (final input in values) {
      var cacheKey = getCacheKey(input, options);
      if (await readCacheAsync(cacheKey, cancellationToken) is TEmbedding) {
        final existing =
            await readCacheAsync(cacheKey, cancellationToken) as TEmbedding;
        results.add(existing);
      } else {
        (uncached ??= []).add((results.count, cacheKey, input));
        results.add(null!);
      }
    }
    if (uncached != null) {
      var uncachedResults = await base.generateAsync(
        uncached.select((e) => e.input),
        options,
        cancellationToken,
      );
      for (var i = 0; i < uncachedResults.count; i++) {
        await writeCacheAsync(
          uncached[i].cacheKey,
          uncachedResults[i],
          cancellationToken,
        );
      }
      for (var i = 0; i < uncachedResults.count; i++) {
        results[uncached[i].index] = uncachedResults[i];
      }
    }
    Debug.assertValue(
      results.all((e) => e != null),
      "Expected all values to be non-null",
    );
    return results;
  }

  /// Computes a cache key for the specified values.
  ///
  /// Returns: The computed key.
  ///
  /// [values] The values to inform the key.
  String getCacheKey(ReadOnlySpan<Object?> values);

  /// Returns a previously cached [Embedding], if available.
  ///
  /// Returns: The previously cached data, if available, otherwise `null`.
  ///
  /// [key] The cache key.
  ///
  /// [cancellationToken] The [CancellationToken] to monitor for cancellation
  /// requests.
  Future<TEmbedding?> readCache(
    String key,
    CancellationToken cancellationToken,
  );

  /// Stores a `TEmbedding` in the underlying cache.
  ///
  /// Returns: A [Task] representing the completion of the operation.
  ///
  /// [key] The cache key.
  ///
  /// [value] The `TEmbedding` to be stored.
  ///
  /// [cancellationToken] The [CancellationToken] to monitor for cancellation
  /// requests.
  Future writeCache(
    String key,
    TEmbedding value,
    CancellationToken cancellationToken,
  );
}
