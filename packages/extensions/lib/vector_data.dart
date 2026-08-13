/// Vector store abstractions — a Dart port of
/// `Microsoft.Extensions.VectorData.Abstractions`.
///
/// Provides a provider-agnostic API for storing, retrieving, and searching
/// records with vector embeddings. Use [VectorStore] to manage collections
/// and [VectorStoreCollection] for CRUD and similarity search.
///
/// ## Collection Schema
///
/// The Dart port has no reflection-based schema discovery, so record shapes
/// are always described explicitly:
///
/// {@example /example/example_vector_data.dart#collection_definition}
///
/// ## Filters
///
/// C# passes `Expression<Func<TRecord, bool>>`; Dart uses a sealed filter
/// hierarchy that providers pattern-match on:
///
/// {@example /example/example_vector_data.dart#vector_store_filter}
///
/// Pair a filter with paging and ordering for filtered retrieval:
///
/// {@example /example/example_vector_data.dart#filtered_retrieval_options}
///
library;

// Core abstractions
export 'src/vector_data/vector_store.dart';
export 'src/vector_data/vector_store_collection.dart';
export 'src/vector_data/vector_searchable.dart';
export 'src/vector_data/keyword_hybrid_searchable.dart';

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

// Provider services (support types for provider implementors)
export 'src/vector_data/provider_services/property_model.dart';
export 'src/vector_data/provider_services/key_property_model.dart';
export 'src/vector_data/provider_services/data_property_model.dart';
export 'src/vector_data/provider_services/vector_property_model.dart';
export 'src/vector_data/provider_services/collection_model.dart';
export 'src/vector_data/provider_services/collection_model_building_options.dart';
export 'src/vector_data/provider_services/collection_model_builder.dart';
export 'src/vector_data/provider_services/embedding_generation_dispatcher.dart';
export 'src/vector_data/provider_services/vector_data_strings.dart';

// Deprecated filter clauses (kept for source compatibility)
// ignore: deprecated_member_use_from_same_package
export 'src/vector_data/filter_clauses/filter_clause.dart';
// ignore: deprecated_member_use_from_same_package
export 'src/vector_data/filter_clauses/equal_to_filter_clause.dart';
// ignore: deprecated_member_use_from_same_package
export 'src/vector_data/filter_clauses/any_tag_equal_to_filter_clause.dart';
