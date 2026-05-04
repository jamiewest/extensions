import '../../evaluation_metric_interpretation.dart';
import '../../evaluation_rating.dart';
import '../../numeric_metric.dart';

extension ScoreInterpretationExtensions on NumericMetric {EvaluationMetricInterpretation interpret() {
var rating = metric.value switch
        {
            (null) => EvaluationRating.inconclusive,
            > 1.0 => EvaluationRating.inconclusive,
            > 0.8 and <= 1.0 => EvaluationRating.exceptional,
            > 0.6 and <= 0.8 => EvaluationRating.good,
            > 0.4 and <= 0.6 => EvaluationRating.average,
            > 0.2 and <= 0.4 => EvaluationRating.poor,
            >= 0.0 and <= 0.2 => EvaluationRating.unacceptable,
            < 0.0 => EvaluationRating.inconclusive,
            (_) => EvaluationRating.inconclusive,
        };
var MinimumPassingScore = 0.5;
return metric.value is double value && value < MinimumPassingScore
            ? evaluationMetricInterpretation(
                rating,
                failed: true,
                reason: '${metric.name} is less than ${MinimumPassingScore}.')
            : evaluationMetricInterpretation(rating);
 }
 }
