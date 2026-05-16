import 'package:extensions/vector_data.dart';
import 'package:test/test.dart';

void main() {
  group('DistanceFunction', () {
    test('constant values match .NET strings exactly', () {
      expect(
        DistanceFunction.cosineSimilarity,
        equals('CosineSimilarity'),
      );
      expect(DistanceFunction.cosineDistance, equals('CosineDistance'));
      expect(
        DistanceFunction.dotProductSimilarity,
        equals('DotProductSimilarity'),
      );
      expect(
        DistanceFunction.negativeDotProductSimilarity,
        equals('NegativeDotProductSimilarity'),
      );
      expect(
        DistanceFunction.euclideanDistance,
        equals('EuclideanDistance'),
      );
      expect(
        DistanceFunction.euclideanSquaredDistance,
        equals('EuclideanSquaredDistance'),
      );
      expect(DistanceFunction.hammingDistance, equals('HammingDistance'));
      expect(DistanceFunction.manhattanDistance, equals('ManhattanDistance'));
    });

    test('all constants are distinct', () {
      final values = {
        DistanceFunction.cosineSimilarity,
        DistanceFunction.cosineDistance,
        DistanceFunction.dotProductSimilarity,
        DistanceFunction.negativeDotProductSimilarity,
        DistanceFunction.euclideanDistance,
        DistanceFunction.euclideanSquaredDistance,
        DistanceFunction.hammingDistance,
        DistanceFunction.manhattanDistance,
      };

      expect(values, hasLength(8));
    });
  });
}
