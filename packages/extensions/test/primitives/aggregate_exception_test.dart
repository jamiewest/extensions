import 'package:extensions/primitives.dart';
import 'package:test/test.dart';

void main() {
  group('AggregateException', () {
    test('creates exception with default message', () {
      var ex = AggregateException();
      expect(ex.message, equals('One or more errors occurred.'));
      expect(ex.innerExceptions, isEmpty);
      expect(ex.count, equals(0));
    });

    test('creates exception with custom message', () {
      var ex = AggregateException(message: 'Custom error message');
      expect(ex.message, equals('Custom error message'));
    });

    test('stores inner exceptions', () {
      var inner1 = Exception('Error 1');
      var inner2 = Exception('Error 2');
      var ex = AggregateException(
        message: 'Multiple errors',
        innerExceptions: [inner1, inner2],
      );

      expect(ex.count, equals(2));
      expect(ex.innerExceptions, hasLength(2));
      expect(ex.innerExceptions[0], equals(inner1));
      expect(ex.innerExceptions[1], equals(inner2));
    });

    test('creates from exceptions list', () {
      var inner1 = Exception('Error 1');
      var inner2 = Exception('Error 2');
      var ex = AggregateException.from([inner1, inner2]);

      expect(ex.count, equals(2));
      expect(ex.innerExceptions[0], equals(inner1));
      expect(ex.innerExceptions[1], equals(inner2));
    });

    test('innerExceptions returns unmodifiable list', () {
      var inner1 = Exception('Error 1');
      var ex = AggregateException(innerExceptions: [inner1]);
      var innerList = ex.innerExceptions;

      expect(() => innerList.add(Exception('Error 2')), throwsUnsupportedError);
    });

    test('toString includes message and inner exceptions', () {
      var inner1 = Exception('Error 1');
      var inner2 = Exception('Error 2');
      var ex = AggregateException(
        message: 'Multiple errors',
        innerExceptions: [inner1, inner2],
      );

      var str = ex.toString();
      expect(str, contains('Multiple errors'));
      expect(str, contains('Error 1'));
      expect(str, contains('Error 2'));
    });

    test('flatten handles nested AggregateExceptions', () {
      var inner1 = Exception('Error 1');
      var inner2 = Exception('Error 2');
      var inner3 = Exception('Error 3');

      var nested1 = AggregateException(innerExceptions: [inner1, inner2]);
      var nested2 = AggregateException(innerExceptions: [inner3]);
      var outer = AggregateException(
        message: 'Outer',
        innerExceptions: [nested1, nested2],
      );

      var flattened = outer.flatten();

      expect(flattened.count, equals(3));
      expect(flattened.innerExceptions[0], equals(inner1));
      expect(flattened.innerExceptions[1], equals(inner2));
      expect(flattened.innerExceptions[2], equals(inner3));
    });

    test('flatten handles deeply nested AggregateExceptions', () {
      var inner1 = Exception('Error 1');
      var inner2 = Exception('Error 2');
      var inner3 = Exception('Error 3');

      var level2 = AggregateException(innerExceptions: [inner2]);
      var level1 = AggregateException(innerExceptions: [inner1, level2]);
      var level0 = AggregateException(innerExceptions: [level1, inner3]);

      var flattened = level0.flatten();

      expect(flattened.count, equals(3));
      expect(flattened.innerExceptions[0], equals(inner1));
      expect(flattened.innerExceptions[1], equals(inner2));
      expect(flattened.innerExceptions[2], equals(inner3));
    });

    test('flatten preserves message', () {
      var inner = Exception('Error 1');
      var nested = AggregateException(innerExceptions: [inner]);
      var outer = AggregateException(
        message: 'Original message',
        innerExceptions: [nested],
      );

      var flattened = outer.flatten();

      expect(flattened.message, equals('Original message'));
    });

    test('flatten with no nested exceptions returns same structure', () {
      var inner1 = Exception('Error 1');
      var inner2 = Exception('Error 2');
      var ex = AggregateException(innerExceptions: [inner1, inner2]);

      var flattened = ex.flatten();

      expect(flattened.count, equals(2));
      expect(flattened.innerExceptions[0], equals(inner1));
      expect(flattened.innerExceptions[1], equals(inner2));
    });
  });
}
