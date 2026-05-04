import 'package:extensions/annotations.dart';

import 'evaluation_diagnostic_severity.dart';

/// A diagnostic message associated with an [EvaluationMetric].
@Source(
  name: 'EvaluationDiagnostic.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation/',
)
class EvaluationDiagnostic {
  /// Creates an [EvaluationDiagnostic] with the given [severity] and [message].
  const EvaluationDiagnostic(this.severity, this.message);

  /// The severity of this diagnostic.
  final EvaluationDiagnosticSeverity severity;

  /// The diagnostic message.
  final String message;

  /// Creates an informational diagnostic.
  factory EvaluationDiagnostic.informational(String message) =>
      EvaluationDiagnostic(EvaluationDiagnosticSeverity.informational, message);

  /// Creates a warning diagnostic.
  factory EvaluationDiagnostic.warning(String message) =>
      EvaluationDiagnostic(EvaluationDiagnosticSeverity.warning, message);

  /// Creates an error diagnostic.
  factory EvaluationDiagnostic.error(String message) =>
      EvaluationDiagnostic(EvaluationDiagnosticSeverity.error, message);

  @override
  String toString() => '${severity.name}: $message';
}
