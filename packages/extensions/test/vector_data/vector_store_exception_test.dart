import 'package:extensions/vector_data.dart';
import 'package:test/test.dart';

void main() {
  group('VectorStoreException', () {
    test('default constructor sets message, cause is null', () {
      final ex = VectorStoreException('something went wrong');

      expect(ex.message, equals('something went wrong'));
      expect(ex.cause, isNull);
    });

    test('default constructor with null message', () {
      final ex = VectorStoreException();

      expect(ex.message, isNull);
      expect(ex.cause, isNull);
    });

    test('withCause sets message and cause', () {
      final inner = Exception('inner');
      final ex = VectorStoreException.withCause('outer', inner);

      expect(ex.message, equals('outer'));
      expect(ex.cause, same(inner));
    });

    test('context properties default to null', () {
      final ex = VectorStoreException('err');

      expect(ex.vectorStoreSystemName, isNull);
      expect(ex.vectorStoreName, isNull);
      expect(ex.collectionName, isNull);
      expect(ex.operationName, isNull);
    });

    test('context properties are mutable', () {
      final ex = VectorStoreException('err')
        ..vectorStoreSystemName = 'Qdrant'
        ..vectorStoreName = 'my-store'
        ..collectionName = 'hotels'
        ..operationName = 'upsert';

      expect(ex.vectorStoreSystemName, equals('Qdrant'));
      expect(ex.vectorStoreName, equals('my-store'));
      expect(ex.collectionName, equals('hotels'));
      expect(ex.operationName, equals('upsert'));
    });

    group('toString', () {
      test('includes context when set', () {
        final ex = VectorStoreException('failed')
          ..vectorStoreSystemName = 'Redis'
          ..collectionName = 'hotels';

        expect(ex.toString(), contains('Redis'));
        expect(ex.toString(), contains('hotels'));
        expect(ex.toString(), contains('failed'));
      });

      test('works with no context', () {
        final ex = VectorStoreException('failed');

        expect(ex.toString(), contains('failed'));
        expect(ex.toString(), contains('VectorStoreException'));
      });

      test('works with null message', () {
        final ex = VectorStoreException();

        expect(ex.toString(), contains('VectorStoreException'));
      });
    });

    test('is an Exception', () {
      final ex = VectorStoreException('err');

      expect(ex, isA<Exception>());
    });
  });
}
