import 'package:extensions/ai.dart';
import 'package:test/test.dart';

/// Mirrors upstream `EvaluationMetricExtensionsTests`
/// (dotnet/extensions #7735): `interpretScore` must fail closed for a metric
/// that carries no score, or a score outside the 1–5 range the ratings cover.
void main() {
  group('NumericMetric.interpretScore - fail closed', () {
    test('metric with no score is failed', () {
      // Arrange
      final metric = NumericMetric('test');

      // Act
      final interpretation = metric.interpretScore();

      // Assert
      expect(interpretation.rating, EvaluationRating.inconclusive);
      expect(interpretation.failed, isTrue);
      expect(interpretation.reason, 'test has no score.');
    });

    for (final value in [5.1, 7.0]) {
      test('score above the maximum ($value) is failed', () {
        // Arrange
        final metric = NumericMetric('test', value: value);

        // Act
        final interpretation = metric.interpretScore();

        // Assert
        expect(interpretation.rating, EvaluationRating.inconclusive);
        expect(interpretation.failed, isTrue);
        expect(interpretation.reason, 'test is outside the valid range.');
      });
    }

    test('score that is not a number is failed', () {
      // Arrange
      final metric = NumericMetric('test', value: double.nan);

      // Act
      final interpretation = metric.interpretScore();

      // Assert
      expect(interpretation.rating, EvaluationRating.inconclusive);
      expect(interpretation.failed, isTrue);
    });

    for (final value in [-1.0, 0.0, 1.0, 3.9]) {
      test('score below the minimum passing score ($value) is failed', () {
        // Arrange
        final metric = NumericMetric('test', value: value);

        // Act
        final interpretation = metric.interpretScore();

        // Assert
        expect(interpretation.failed, isTrue);
      });
    }

    for (final value in [4.0, 4.5, 5.0]) {
      test('score at or above the minimum passing score ($value) passes', () {
        // Arrange
        final metric = NumericMetric('test', value: value);

        // Act
        final interpretation = metric.interpretScore();

        // Assert
        expect(interpretation.failed, isFalse);
        expect(interpretation.reason, isNull);
      });
    }
  });

  group('NumericMetric.interpretScore - ratings', () {
    // Upstream bands: (4,5] exceptional, (3,4] good, (2,3] average,
    // (1,2] poor, (0,1] unacceptable, and inconclusive outside that range.
    final cases = <double, EvaluationRating>{
      5.0: EvaluationRating.exceptional,
      4.5: EvaluationRating.exceptional,
      4.0: EvaluationRating.good,
      3.5: EvaluationRating.good,
      3.0: EvaluationRating.average,
      2.5: EvaluationRating.average,
      2.0: EvaluationRating.poor,
      1.5: EvaluationRating.poor,
      1.0: EvaluationRating.unacceptable,
      0.5: EvaluationRating.unacceptable,
      0.0: EvaluationRating.inconclusive,
      5.5: EvaluationRating.inconclusive,
    };

    cases.forEach((value, expected) {
      test('$value is rated ${expected.name}', () {
        // Arrange
        final metric = NumericMetric('test', value: value);

        // Act
        final interpretation = metric.interpretScore();

        // Assert
        expect(interpretation.rating, expected);
      });
    });
  });
}
