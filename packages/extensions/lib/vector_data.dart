/// Vector store abstractions — a Dart port of
/// `Microsoft.Extensions.VectorData.Abstractions`.
///
/// Provides a provider-agnostic API for storing, retrieving, and searching
/// records with vector embeddings. Use [VectorStore] to manage collections
/// and [VectorStoreCollection] for CRUD and similarity search.
///
/// Example:
/// ```dart
/// import 'package:extensions/vector_data.dart';
///
/// // Define schema explicitly.
/// final definition = VectorStoreCollectionDefinition(
///   properties: [
///     VectorStoreKeyProperty('id'),
///     VectorStoreDataProperty('content')..isFullTextIndexed = true,
///     VectorStoreVectorProperty('embedding', dimensions: 1536),
///   ],
/// );
///
/// // Obtain a typed collection from any VectorStore implementation.
/// final collection = store.getCollection<String, Hotel>(
///   'hotels',
///   definition: definition,
/// );
///
/// await collection.ensureCollectionExistsAsync();
///
/// // Search for similar records.
/// final results = await collection
///   .searchAsync(
///     queryEmbedding,
///     top: 5,
///     options: VectorSearchOptions(
///       filter: VectorStoreFilter.equalTo('category', 'suite'),
///       scoreThreshold: 0.75,
///     ),
///   )
///   .toList();
/// ```
library;

// Core abstractions
export 'src/vector_data/vector_store.dart';
export 'src/vector_data/vector_store_collection.dart';
export 'src/vector_data/i_vector_searchable.dart';
export 'src/vector_data/i_keyword_hybrid_searchable.dart';

// Search results & options
export 'src/vector_data/vector_search_result.dart';
export 'src/vector_data/vector_search_options.dart';
export 'src/vector_data/hybrid_search_options.dart';
export 'src/vector_data/record_retrieval_options.dart';
export 'src/vector_data/filtered_record_retrieval_options.dart';
export 'src/vector_data/vector_store_collection_options.dart';
export 'src/vector_data/vector_store_filter.dart';

// Metadata & exceptions
export 'src/vector_data/vector_store_metadata.dart';
export 'src/vector_data/vector_store_collection_metadata.dart';
export 'src/vector_data/vector_store_exception.dart';

// Attributes (annotation classes for code generators and documentation)
export 'src/vector_data/attributes/vector_store_key_attribute.dart';
export 'src/vector_data/attributes/vector_store_data_attribute.dart';
export 'src/vector_data/attributes/vector_store_vector_attribute.dart';

// Record definition (explicit schema types)
export 'src/vector_data/record_definition/index_kind.dart';
export 'src/vector_data/record_definition/distance_function.dart';
export 'src/vector_data/record_definition/vector_store_property.dart';
export 'src/vector_data/record_definition/vector_store_key_property.dart';
export 'src/vector_data/record_definition/vector_store_data_property.dart';
export 'src/vector_data/record_definition/vector_store_vector_property.dart';
export 'src/vector_data/record_definition/vector_store_collection_definition.dart';

// Deprecated filter clauses (kept for source compatibility)
// ignore: deprecated_member_use_from_same_package
export 'src/vector_data/filter_clauses/filter_clause.dart';
// ignore: deprecated_member_use_from_same_package
export 'src/vector_data/filter_clauses/equal_to_filter_clause.dart';
// ignore: deprecated_member_use_from_same_package
export 'src/vector_data/filter_clauses/any_tag_equal_to_filter_clause.dart';
