import 'package:extensions/annotations.dart';

import 'content_safety_evaluator.dart';
import 'hate_and_unfairness_evaluator.dart';
import 'self_harm_evaluator.dart';
import 'sexual_evaluator.dart';
import 'violence_evaluator.dart';

/// Evaluates AI responses for all supported content harm categories:
/// hate/unfairness, violence, self-harm, and sexual content.
///
/// Returns four [NumericMetric]s with severity scores 0–7 (fail above 0).
@Source(
  name: 'ContentHarmEvaluator.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Safety',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Safety/',
)
class ContentHarmEvaluator extends ContentSafetyEvaluator {
  /// Creates a [ContentHarmEvaluator].
  ContentHarmEvaluator({
    required super.configuration,
    Map<String, String>? metricNames,
  }) : super(
          annotationTask: 'content harm',
          metricNames: metricNames ?? _defaultMetricNames,
        );

  static const _defaultMetricNames = {
    'hate_unfairness': HateAndUnfairnessEvaluator.hateAndUnfairnessMetricName,
    'violence': ViolenceEvaluator.violenceMetricName,
    'self_harm': SelfHarmEvaluator.selfHarmMetricName,
    'sexual': SexualEvaluator.sexualMetricName,
  };
}
