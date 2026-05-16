import 'package:extensions/vector_data.dart';
import 'package:test/test.dart';

void main() {
  group('VectorStoreFilter', () {
    group('equalTo', () {
      test('creates EqualToVectorStoreFilter with field and value', () {
        final filter = VectorStoreFilter.equalTo('category', 'hotel');

        expect(filter, isA<EqualToVectorStoreFilter>());
        expect(filter.fieldName, equals('category'));
        expect(filter.value, equals('hotel'));
      });

      test('accepts null value', () {
        final filter = VectorStoreFilter.equalTo('deleted', null);

        expect(filter.value, isNull);
      });

      test('accepts numeric value', () {
        final filter = VectorStoreFilter.equalTo('rating', 5);

        expect(filter.value, equals(5));
      });
    });

    group('anyTagEqualTo', () {
      test('creates AnyTagEqualToVectorStoreFilter', () {
        final filter = VectorStoreFilter.anyTagEqualTo('tags', 'pool');

        expect(filter, isA<AnyTagEqualToVectorStoreFilter>());
        expect(filter.fieldName, equals('tags'));
        expect(filter.value, equals('pool'));
      });
    });

    group('and', () {
      test('creates AndVectorStoreFilter with all sub-filters', () {
        final f1 = VectorStoreFilter.equalTo('a', 1);
        final f2 = VectorStoreFilter.equalTo('b', 2);
        final filter = VectorStoreFilter.and([f1, f2]);

        expect(filter, isA<AndVectorStoreFilter>());
        expect(filter.filters, hasLength(2));
        expect(filter.filters[0], same(f1));
        expect(filter.filters[1], same(f2));
      });

      test('accepts empty list', () {
        final filter = VectorStoreFilter.and([]);

        expect(filter.filters, isEmpty);
      });
    });

    group('or', () {
      test('creates OrVectorStoreFilter with all sub-filters', () {
        final f1 = VectorStoreFilter.equalTo('status', 'active');
        final f2 = VectorStoreFilter.equalTo('status', 'pending');
        final filter = VectorStoreFilter.or([f1, f2]);

        expect(filter, isA<OrVectorStoreFilter>());
        expect(filter.filters, hasLength(2));
      });
    });

    group('sealed exhaustiveness', () {
      test('all variants are coverable via pattern matching', () {
        final filters = <VectorStoreFilter>[
          VectorStoreFilter.equalTo('f', 1),
          VectorStoreFilter.anyTagEqualTo('t', 'v'),
          VectorStoreFilter.and([]),
          VectorStoreFilter.or([]),
        ];

        for (final filter in filters) {
          final matched = switch (filter) {
            EqualToVectorStoreFilter() => 'equal',
            AnyTagEqualToVectorStoreFilter() => 'anyTag',
            AndVectorStoreFilter() => 'and',
            OrVectorStoreFilter() => 'or',
          };
          expect(matched, isNotEmpty);
        }
      });
    });
  });
}
