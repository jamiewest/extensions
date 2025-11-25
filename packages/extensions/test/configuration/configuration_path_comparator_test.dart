import 'package:extensions/src/configuration/configuration_key_comparator.dart';
import 'package:test/test.dart';

void main() {
  group('ConfigurationPathComparator', () {
    test('CompareWithNull', () {
      _comparatorTest(null, null, 0);
      _comparatorTest(null, 'a', -1);
      _comparatorTest('b', null, 1);
    });

    test('CompareWithSameLength', () {
      _comparatorTest('a', 'a', 0);
      _comparatorTest('a', 'A', 0);
      _comparatorTest('aB', 'Ab', 0);
    });

    test('CompareWithDifferentLengths', () {
      _comparatorTest('a', 'aa', -1);
      _comparatorTest('aa', 'a', 1);
    });

    test('CompareWithLetters', () {
      _comparatorTest('a', 'b', -1);
      _comparatorTest('b', 'a', 1);
    });

    test('CompareWithNumbers', () {
      _comparatorTest('000', '0', 0);
      _comparatorTest('001', '1', 0);
      _comparatorTest('1', '1', 0);
      _comparatorTest('1', '10', -1);
      _comparatorTest('10', '1', 1);
      _comparatorTest('2', '10', -1);
      _comparatorTest('10', '2', 1);
    });

    test('CompareWithNumbersAndLetters', () {
      _comparatorTest('1', 'a', -1);
      _comparatorTest('a', '1', 1);
      _comparatorTest('100', 'a', -1);
      _comparatorTest('a', '100', 1);
    });

    test('CompareWithNonNumbers', () {
      _comparatorTest('1a', '100', 1);
      _comparatorTest('100', '1a', -1);

      _comparatorTest('100a', '100', 1);
      _comparatorTest('100', '100a', -1);

      _comparatorTest('a100', '100', 1);
      _comparatorTest('100', 'a100', -1);

      _comparatorTest('1a', 'a', -1);
      _comparatorTest('a', '1a', 1);
    });

    test('CompareIdenticalPaths', () {
      _comparatorTest('abc:DEF:0:a100', 'ABC:DEF:0:a100', 0);
    });

    test('CompareDifferentPaths', () {
      _comparatorTest('abc:def', 'ghi:2', -1);
      _comparatorTest('ghi:2', 'abc:def', 1);
    });

    test('ComparePathsWithCommonPart', () {
      _comparatorTest('abc:def:XYQ', 'abc:def:XYZ', -1);
      _comparatorTest('abc:def:XYZ', 'abc:def:XYQ', 1);
    });

    test('ComparePathsWithCommonPartButShorter', () {
      _comparatorTest('abc:def', 'abc:def:ghi', -1);
      _comparatorTest('abc:def:ghi', 'abc:def', 1);
    });

    test('ComparePathsWithIndicesAtTheEnd', () {
      _comparatorTest('abc:def:2', 'abc:def:10', -1);
      _comparatorTest('abc:def:10', 'abc:def:2', 1);

      _comparatorTest('abc:def:10', 'abc:def:22', -1);
      _comparatorTest('abc:def:22', 'abc:def:10', 1);
    });

    test('ComparePathsWithIndicesInside', () {
      _comparatorTest('abc:def:1000:jkl', 'abc:def:ghi:jkl', -1);
      _comparatorTest('abc:def:ghi:jkl', 'abc:def:1000:jkl', 1);

      _comparatorTest('abc:def:10:jkl', 'abc:def:22:jkl', -1);
      _comparatorTest('abc:def:22:jkl', 'abc:def:10:jkl', 1);
    });
  });
}

void _comparatorTest(String? a, String? b, int expectedSign) {
  var result = configurationKeyComparator(a, b);
  expect(result.sign, expectedSign);
}
