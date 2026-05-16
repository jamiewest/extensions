import 'package:extensions/vector_data.dart';
import 'package:test/test.dart';

void main() {
  group('OrderByClause', () {
    test('ascending sets descending to false', () {
      const clause = OrderByClause.ascending('rating');

      expect(clause.fieldName, equals('rating'));
      expect(clause.descending, isFalse);
    });

    test('descending sets descending to true', () {
      const clause = OrderByClause.descending('createdAt');

      expect(clause.fieldName, equals('createdAt'));
      expect(clause.descending, isTrue);
    });
  });

  group('FilteredRecordRetrievalOptions', () {
    test('has correct defaults', () {
      final options = FilteredRecordRetrievalOptions<String>();

      expect(options.skip, equals(0));
      expect(options.includeVectors, isFalse);
      expect(options.scoreThreshold, isNull);
      expect(options.orderBy, isNull);
      expect(options.filter, isNull);
    });

    test('accepts all parameters', () {
      final filter = VectorStoreFilter.equalTo('active', true);
      final orderBy = [
        const OrderByClause.ascending('name'),
        const OrderByClause.descending('rating'),
      ];
      final options = FilteredRecordRetrievalOptions<String>(
        skip: 10,
        includeVectors: true,
        scoreThreshold: 0.6,
        orderBy: orderBy,
      );
      options.filter = filter;

      expect(options.skip, equals(10));
      expect(options.includeVectors, isTrue);
      expect(options.scoreThreshold, equals(0.6));
      expect(options.orderBy, same(orderBy));
      expect(options.filter, same(filter));
    });

    test('fields are mutable', () {
      final options = FilteredRecordRetrievalOptions<String>();
      final clauses = [const OrderByClause.ascending('name')];

      options.skip = 5;
      options.includeVectors = true;
      options.scoreThreshold = 0.9;
      options.orderBy = clauses;

      expect(options.skip, equals(5));
      expect(options.includeVectors, isTrue);
      expect(options.scoreThreshold, equals(0.9));
      expect(options.orderBy, same(clauses));
    });

    test('orderBy list preserves order', () {
      final clauses = [
        const OrderByClause.ascending('a'),
        const OrderByClause.descending('b'),
        const OrderByClause.ascending('c'),
      ];
      final options = FilteredRecordRetrievalOptions<String>(orderBy: clauses);

      expect(options.orderBy![0].fieldName, equals('a'));
      expect(options.orderBy![0].descending, isFalse);
      expect(options.orderBy![1].fieldName, equals('b'));
      expect(options.orderBy![1].descending, isTrue);
      expect(options.orderBy![2].fieldName, equals('c'));
    });
  });
}
