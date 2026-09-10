import 'package:extensions/ai.dart';
import 'package:test/test.dart';

void main() {
  group('NumericMetric.interpretScore', () {
    test('fails a metric that has no score', () {
      final metric = NumericMetric('Coherence');

      final interpretation = metric.interpretScore();

      expect(interpretation.rating, EvaluationRating.inconclusive);
      expect(interpretation.failed, isTrue);
      expect(interpretation.reason, 'Coherence has no score.');
    });

    test('fails a score below the minimum passing score', () {
      final metric = NumericMetric('Coherence', value: 3.0);

      final interpretation = metric.interpretScore();

      expect(interpretation.rating, EvaluationRating.average);
      expect(interpretation.failed, isTrue);
      expect(interpretation.reason, 'Coherence is less than 4.0.');
    });

    test('fails a score above the scale the ratings cover', () {
      final metric = NumericMetric('Coherence', value: 6.0);

      final interpretation = metric.interpretScore();

      expect(interpretation.rating, EvaluationRating.inconclusive);
      expect(interpretation.failed, isTrue);
      expect(interpretation.reason, 'Coherence is outside the valid range.');
    });

    test('fails a score at or below zero', () {
      final metric = NumericMetric('Coherence', value: 0.0);

      final interpretation = metric.interpretScore();

      expect(interpretation.rating, EvaluationRating.inconclusive);
      expect(interpretation.failed, isTrue);
      expect(interpretation.reason, 'Coherence is less than 4.0.');
    });

    test('passes a score at the top of the scale', () {
      final metric = NumericMetric('Coherence', value: 5.0);

      final interpretation = metric.interpretScore();

      expect(interpretation.rating, EvaluationRating.exceptional);
      expect(interpretation.failed, isFalse);
      expect(interpretation.reason, isNull);
    });

    test('passes a score at the minimum passing score', () {
      final metric = NumericMetric('Coherence', value: 4.0);

      final interpretation = metric.interpretScore();

      expect(interpretation.rating, EvaluationRating.good);
      expect(interpretation.failed, isFalse);
    });

    test('rates the bands the way the upstream scale does', () {
      EvaluationRating ratingFor(double value) =>
          NumericMetric('Coherence', value: value).interpretScore().rating;

      expect(ratingFor(4.5), EvaluationRating.exceptional);
      expect(ratingFor(3.5), EvaluationRating.good);
      expect(ratingFor(2.5), EvaluationRating.average);
      expect(ratingFor(1.5), EvaluationRating.poor);
      expect(ratingFor(0.5), EvaluationRating.unacceptable);
    });
  });
}
