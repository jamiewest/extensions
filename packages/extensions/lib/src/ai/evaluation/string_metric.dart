import 'package:extensions/annotations.dart';

import 'evaluation_metric.dart';

/// An [EvaluationMetric] with a string value.
///
/// Commonly used to represent one value from an enumeration of possible
/// categorical outcomes.
@Source(
  name: 'StringMetric.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation/',
)
class StringMetric extends EvaluationMetric {
  /// Creates a [StringMetric] with the given [name], optional [value], and
  /// optional [reason].
  StringMetric(super.name, {this.value, super.reason});

  /// The string value of this metric.
  String? value;
}
