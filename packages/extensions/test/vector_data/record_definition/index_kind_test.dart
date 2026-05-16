import 'package:extensions/vector_data.dart';
import 'package:test/test.dart';

void main() {
  group('IndexKind', () {
    test('constant values match .NET strings exactly', () {
      expect(IndexKind.hnsw, equals('Hnsw'));
      expect(IndexKind.flat, equals('Flat'));
      expect(IndexKind.ivfFlat, equals('IvfFlat'));
      expect(IndexKind.diskAnn, equals('DiskAnn'));
      expect(IndexKind.quantizedFlat, equals('QuantizedFlat'));
      expect(IndexKind.dynamic, equals('Dynamic'));
    });

    test('all constants are distinct', () {
      final values = {
        IndexKind.hnsw,
        IndexKind.flat,
        IndexKind.ivfFlat,
        IndexKind.diskAnn,
        IndexKind.quantizedFlat,
        IndexKind.dynamic,
      };

      expect(values, hasLength(6));
    });
  });
}
