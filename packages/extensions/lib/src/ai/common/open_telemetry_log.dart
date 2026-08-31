import '../../logging/logger.dart';
import '../../logging/logger_extensions.dart';

/// Shared log methods for OpenTelemetry instrumentation classes.
///
/// Upstream also stamps the error tag and status on the active
/// `Activity`; the Dart port has no Activity equivalent (spans are
/// `dart:developer` Timeline events), so only the logging side is
/// ported.
///
/// Not exported from the `ai` barrel; this mirrors the C# `internal`
/// type.
abstract final class OpenTelemetryLog {
  /// Logs [error] as a `gen_ai.client.operation.exception` warning.
  ///
  /// No-op when [error] or [logger] is `null`.
  static void recordOperationError(Logger? logger, Object? error) {
    if (error == null || logger == null) {
      return;
    }
    logger.logWarning('gen_ai.client.operation.exception', error: error);
  }
}
