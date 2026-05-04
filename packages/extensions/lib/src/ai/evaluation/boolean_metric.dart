import 'package:extensions/annotations.dart';

import 'evaluation_metric.dart';

/// An [EvaluationMetric] with a boolean value (pass/fail or yes/no).
@Source(
  name: 'BooleanMetric.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation/',
)
class BooleanMetric extends EvaluationMetric {
  /// Creates a [BooleanMetric] with the given [name], optional [value], and
  /// optional [reason].
  BooleanMetric(super.name, {this.value, super.reason});

  /// The boolean value of this metric.
  bool? value;
}
