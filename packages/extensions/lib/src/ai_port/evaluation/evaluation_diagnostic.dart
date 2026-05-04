import 'evaluation_diagnostic_severity.dart';

/// Represents a diagnostic (such as a warning, error or informational
/// message) that applies to the result represented in an [EvaluationMetric].
///
/// [severity] An [EvaluationDiagnosticSeverity] that indicates the severity
/// of the [EvaluationDiagnostic].
///
/// [message] An error, warning or informational message describing the
/// [EvaluationDiagnostic].
class EvaluationDiagnostic {
  /// Represents a diagnostic (such as a warning, error or informational
  /// message) that applies to the result represented in an [EvaluationMetric].
  ///
  /// [severity] An [EvaluationDiagnosticSeverity] that indicates the severity
  /// of the [EvaluationDiagnostic].
  ///
  /// [message] An error, warning or informational message describing the
  /// [EvaluationDiagnostic].
  const EvaluationDiagnostic(
    EvaluationDiagnosticSeverity severity,
    String message,
  ) : severity = severity,
      message = message;

  /// Gets or sets an [EvaluationDiagnosticSeverity] that indicates the severity
  /// of the [EvaluationDiagnostic].
  EvaluationDiagnosticSeverity severity = severity;

  /// Gets or sets an error, warning or informational message describing the
  /// [EvaluationDiagnostic].
  String message = message;

  /// Returns an [EvaluationDiagnostic] with the supplied `message` and with
  /// [Severity] set to [Informational].
  ///
  /// Returns: An [EvaluationDiagnostic] with [Severity] set to [Informational].
  ///
  /// [message] An informational message describing the [EvaluationDiagnostic].
  static EvaluationDiagnostic informational(String message) {
    return evaluationDiagnostic(
      EvaluationDiagnosticSeverity.informational,
      message,
    );
  }

  /// Returns an [EvaluationDiagnostic] with the supplied `message` and with
  /// [Severity] set to [Warning].
  ///
  /// Returns: An [EvaluationDiagnostic] with [Severity] set to [Warning].
  ///
  /// [message] A warning message describing the [EvaluationDiagnostic].
  static EvaluationDiagnostic warning(String message) {
    return evaluationDiagnostic(EvaluationDiagnosticSeverity.warning, message);
  }

  /// Returns an [EvaluationDiagnostic] with the supplied `message` and with
  /// [Severity] set to [Error].
  ///
  /// Returns: An [EvaluationDiagnostic] with [Severity] set to [Error].
  ///
  /// [message] An error message describing the [EvaluationDiagnostic].
  static EvaluationDiagnostic error(String message) {
    return evaluationDiagnostic(EvaluationDiagnosticSeverity.error, message);
  }

  /// Returns a string representation of the [EvaluationDiagnostic].
  ///
  /// Returns: A string representation of the [EvaluationDiagnostic].
  @override
  String toString() {
    return '${severity}: ${message}';
  }
}
