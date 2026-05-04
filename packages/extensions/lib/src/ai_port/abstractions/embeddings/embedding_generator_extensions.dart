import 'embedding_generation_options.dart';
import 'generated_embeddings.dart';

/// Provides a collection of static methods for extending [EmbeddingGenerator]
/// instances.
extension EmbeddingGeneratorExtensions on EmbeddingGenerator {
  /// Asks the [EmbeddingGenerator] for an object of type `TService`.
///
/// Remarks: The purpose of this method is to allow for the retrieval of
/// strongly typed services that may be provided by the [EmbeddingGenerator],
/// including itself or any services it might be wrapping.
///
/// Returns: The found object, otherwise `null`.
///
/// [generator] The generator.
///
/// [serviceKey] An optional key that can be used to help identify the target
/// service.
///
/// [TService] The type of the object to be retrieved.
TService? getService<TService>({Object? serviceKey}) {
_ = Throw.ifNull(generator);
return generator.getService(typeof(TService), serviceKey) is TService service ? service : default;
 }
/// Asks the [EmbeddingGenerator] for an object of the specified type
/// `serviceType` and throws an exception if one isn't available.
///
/// Remarks: The purpose of this method is to allow for the retrieval of
/// services that are required to be provided by the [EmbeddingGenerator],
/// including itself or any services it might be wrapping.
///
/// Returns: The found object.
///
/// [generator] The generator.
///
/// [serviceType] The type of object being requested.
///
/// [serviceKey] An optional key that can be used to help identify the target
/// service.
Object getRequiredService(Object? serviceKey, {Type? serviceType, }) {
_ = Throw.ifNull(generator);
_ = Throw.ifNull(serviceType);
return generator.getService(serviceType, serviceKey) ??
            throw Throw.createMissingServiceException(serviceType, serviceKey);
 }
/// Generates an embedding vector from the specified `value`.
///
/// Remarks: This operation is equivalent to using [CancellationToken)] and
/// returning the resulting [Embedding]'s [Vector] property.
///
/// Returns: The generated embedding for the specified `value`.
///
/// [generator] The embedding generator.
///
/// [value] A value from which an embedding will be generated.
///
/// [options] The embedding generation options to configure the request.
///
/// [cancellationToken] The [CancellationToken] to monitor for cancellation
/// requests. The default is [None].
///
/// [TInput] The type from which embeddings will be generated.
///
/// [TEmbeddingElement] The numeric type of the embedding data.
Future<ReadOnlyMemory<TEmbeddingElement>> generateVector<TInput,TEmbeddingElement>(
  TInput value,
  {EmbeddingGenerationOptions? options, CancellationToken? cancellationToken, },
) async  {
var embedding = await generateAsync(
  generator,
  value,
  options,
  cancellationToken,
) .configureAwait(false);
return embedding.vector;
 }
/// Generates an embedding from the specified `value`.
///
/// Remarks: This operations is equivalent to using [CancellationToken)] with
/// a collection composed of the single `value` and then returning the first
/// embedding element from the resulting [GeneratedEmbeddings] collection.
///
/// Returns: The generated embedding for the specified `value`.
///
/// [generator] The embedding generator.
///
/// [value] A value from which an embedding will be generated.
///
/// [options] The embedding generation options to configure the request.
///
/// [cancellationToken] The [CancellationToken] to monitor for cancellation
/// requests. The default is [None].
///
/// [TInput] The type from which embeddings will be generated.
///
/// [TEmbedding] The type of embedding to generate.
Future<TEmbedding> generate<TEmbedding>(
  TInput value,
  {EmbeddingGenerationOptions? options, CancellationToken? cancellationToken, },
) async  {
_ = Throw.ifNull(generator);
_ = Throw.ifNull(value);
var embeddings = await generator.generateAsync(
  [value],
  options,
  cancellationToken,
) .configureAwait(false);
if (embeddings == null) {
  Throw.invalidOperationException("Embedding generator returned a null collection of embeddings.");
}
if (embeddings.count != 1) {
  Throw.invalidOperationException('Expected the number of embeddings (${embeddings.count}) to match the number of inputs (1).');
}
var embedding = embeddings[0];
if (embedding == null) {
  Throw.invalidOperationException("Embedding generator generated a null embedding.");
}
return embedding;
 }
/// Generates embeddings for each of the supplied `values` and produces a list
/// that pairs each input value with its resulting embedding.
///
/// Returns: An array containing tuples of the input values and the associated
/// generated embeddings.
///
/// [generator] The embedding generator.
///
/// [values] The collection of values for which to generate embeddings.
///
/// [options] The embedding generation options to configure the request.
///
/// [cancellationToken] The [CancellationToken] to monitor for cancellation
/// requests. The default is [None].
///
/// [TInput] The type from which embeddings will be generated.
///
/// [TEmbedding] The type of embedding to generate.
Future<TInputValue, List<TEmbeddingEmbedding>> generateAndZip<TEmbedding>(
  Iterable<TInput> values,
  {EmbeddingGenerationOptions? options, CancellationToken? cancellationToken, },
) async  {
_ = Throw.ifNull(generator);
_ = Throw.ifNull(values);
var inputs = values as IList<TInput> ?? values.toList();
var inputsCount = inputs.count;
if (inputsCount == 0) {
  return Array.empty<(TInput, TEmbedding)>();
}
var embeddings = await generator.generateAsync(
  values,
  options,
  cancellationToken,
) .configureAwait(false);
if (embeddings.count != inputsCount) {
  Throw.invalidOperationException('Expected the number of embeddings (${embeddings.count}) to match the number of inputs (${inputsCount}).');
}
var results = new (TInput, TEmbedding)[embeddings.count];
for (var i = 0; i < results.length; i++) {
  results[i] = (inputs[i], embeddings[i]);
}
return results;
 }
 }
