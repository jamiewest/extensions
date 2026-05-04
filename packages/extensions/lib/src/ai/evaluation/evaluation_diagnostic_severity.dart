import 'package:extensions/annotations.dart';

/// Severity of an [EvaluationDiagnostic].
@Source(
  name: 'EvaluationDiagnosticSeverity.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation/',
)
enum EvaluationDiagnosticSeverity {
  /// An informational message.
  informational,

  /// A warning message.
  warning,

  /// An error message.
  error,
}
