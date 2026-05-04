import 'evaluation_diagnostic.dart';

/// An enumeration that identifies the set of possible values for [Severity].
enum EvaluationDiagnosticSeverity {
  /// A value that indicates that the [EvaluationDiagnostic] is informational.
  informational,

  /// A value that indicates that the [EvaluationDiagnostic] represents a
  /// warning.
  warning,

  /// A value that indicates that the [EvaluationDiagnostic] represents an
  /// error.
  error,
}
