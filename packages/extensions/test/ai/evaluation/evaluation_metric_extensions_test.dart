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

    test('fails a score that is not a number', () {
      final metric = NumericMetric('Coherence', value: double.nan);

      final interpretation = metric.interpretScore();

      expect(interpretation.rating, EvaluationRating.inconclusive);
      expect(interpretation.failed, isTrue);
      expect(interpretation.reason, 'Coherence is outside the valid range.');
    });

    test('rates every band the way the upstream scale does', () {
      // Upstream bands: (4,5] exceptional, (3,4] good, (2,3] average,
      // (1,2] poor, (0,1] unacceptable, inconclusive outside that range.
      const cases = <(double, EvaluationRating)>[
        (5.5, EvaluationRating.inconclusive),
        (5.0, EvaluationRating.exceptional),
        (4.5, EvaluationRating.exceptional),
        (4.0, EvaluationRating.good),
        (3.5, EvaluationRating.good),
        (3.0, EvaluationRating.average),
        (2.5, EvaluationRating.average),
        (2.0, EvaluationRating.poor),
        (1.5, EvaluationRating.poor),
        (1.0, EvaluationRating.unacceptable),
        (0.5, EvaluationRating.unacceptable),
        (0.0, EvaluationRating.inconclusive),
        (-1.0, EvaluationRating.inconclusive),
      ];

      for (final (value, expected) in cases) {
        expect(
          NumericMetric('Coherence', value: value).interpretScore().rating,
          expected,
          reason: '$value should be rated ${expected.name}',
        );
      }
    });

    test('fails every score below the minimum passing score', () {
      for (final value in [-1.0, 0.0, 1.0, 2.0, 3.0, 3.9]) {
        expect(
          NumericMetric('Coherence', value: value).interpretScore().failed,
          isTrue,
          reason: '$value should fail',
        );
      }
    });
  });

  group('QualityEvaluatorBase interpretation wiring', () {
    test('an unscored metric carries a failed interpretation', () {
      // Mirrors what the quality evaluators do when the judge's reply
      // cannot be parsed: the metric keeps no value, but must still be
      // interpreted, or a caller gating on `failed` reads null as a pass.
      final metric = NumericMetric('Coherence');

      metric.interpretation = metric.interpretScore();

      expect(metric.interpretation!.failed, isTrue);
      expect(metric.interpretation!.rating, EvaluationRating.inconclusive);
    });
  });
}
