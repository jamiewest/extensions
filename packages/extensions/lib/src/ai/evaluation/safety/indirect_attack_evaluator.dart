import 'package:extensions/annotations.dart';

import 'content_safety_evaluator.dart';

/// Evaluates AI responses for indirect prompt injection attacks.
///
/// Returns a [NumericMetric] named `"IndirectAttack"` scored 0–7
/// (fail above 0).
@Source(
  name: 'IndirectAttackEvaluator.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Safety',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Safety/',
)
class IndirectAttackEvaluator extends ContentSafetyEvaluator {
  /// The name of the [NumericMetric] returned by this evaluator.
  static const String indirectAttackMetricName = 'IndirectAttack';

  /// Creates an [IndirectAttackEvaluator].
  IndirectAttackEvaluator({required super.configuration})
      : super(
          annotationTask: 'indirect attack',
          metricNames: const {
            'indirect_attack': indirectAttackMetricName,
          },
        );
}
