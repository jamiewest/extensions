import 'package:extensions/vector_data.dart';

/// Demonstrates describing a vector collection schema and composing filters.
///
/// Run this file to print a collection definition and the filter trees that a
/// provider translates into its own query language.
void main() {
  print('=== Vector Data Example ===');

  _collectionDefinitionExample();
  _filterExample();
  _retrievalOptionsExample();
}

/// Describes a record schema explicitly, without reflection.
void _collectionDefinitionExample() {
  print('--- Collection Definition ---');

  // #region collection_definition
  // The Dart port has no reflection-based schema discovery, so the record
  // shape is always described explicitly.
  final definition = VectorStoreCollectionDefinition(
    properties: [
      VectorStoreKeyProperty('id'),
      VectorStoreDataProperty('content')..isFullTextIndexed = true,
      VectorStoreDataProperty('category')..isIndexed = true,
      VectorStoreVectorProperty('embedding', dimensions: 1536)
        ..distanceFunction = DistanceFunction.cosineSimilarity
        ..indexKind = IndexKind.hnsw,
    ],
  );
  // #endregion

  for (final property in definition.properties) {
    print('${property.runtimeType}: ${property.propertyName}');
  }
}

/// Builds filters as a value tree rather than a LINQ expression.
void _filterExample() {
  print('--- Filters ---');

  // #region vector_store_filter
  // C# passes `Expression<Func<TRecord, bool>>`; Dart uses a sealed filter
  // hierarchy that providers pattern-match on.
  final filter = VectorStoreFilter.and([
    VectorStoreFilter.equalTo('category', 'docs'),
    VectorStoreFilter.or([
      VectorStoreFilter.anyTagEqualTo('tags', 'dart'),
      VectorStoreFilter.anyTagEqualTo('tags', 'flutter'),
    ]),
  ]);
  // #endregion

  print(_describe(filter));
}

/// Pairs a filter with paging and ordering.
void _retrievalOptionsExample() {
  print('--- Filtered Retrieval Options ---');

  // #region filtered_retrieval_options
  final options = FilteredRecordRetrievalOptions<Object>(
    skip: 10,
    includeVectors: false,
    scoreThreshold: 0.75,
    orderBy: const [
      OrderByClause.descending('createdAt'),
      OrderByClause.ascending('id'),
    ],
  );
  // #endregion

  print('skip: ${options.skip}, threshold: ${options.scoreThreshold}');
  for (final clause in options.orderBy ?? const <OrderByClause>[]) {
    print('order by ${clause.fieldName} desc=${clause.descending}');
  }
}

/// Renders a filter tree the way a provider's translator would walk it.
String _describe(VectorStoreFilter filter) => switch (filter) {
  EqualToVectorStoreFilter(:final fieldName, :final value) =>
    '$fieldName == $value',
  AnyTagEqualToVectorStoreFilter(:final fieldName, :final value) =>
    '$fieldName contains $value',
  AndVectorStoreFilter(:final filters) =>
    '(${filters.map(_describe).join(' AND ')})',
  OrVectorStoreFilter(:final filters) =>
    '(${filters.map(_describe).join(' OR ')})',
};
