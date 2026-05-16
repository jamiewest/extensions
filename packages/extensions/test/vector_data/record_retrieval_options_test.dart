import 'package:extensions/vector_data.dart';
import 'package:test/test.dart';

void main() {
  group('RecordRetrievalOptions', () {
    test('defaults to includeVectors false', () {
      final options = RecordRetrievalOptions();

      expect(options.includeVectors, isFalse);
    });

    test('constructor accepts includeVectors', () {
      final options = RecordRetrievalOptions(includeVectors: true);

      expect(options.includeVectors, isTrue);
    });

    test('includeVectors is mutable', () {
      final options = RecordRetrievalOptions();
      options.includeVectors = true;

      expect(options.includeVectors, isTrue);
    });
  });
}
