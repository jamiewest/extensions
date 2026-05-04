import '../open_telemetry_consts.dart';

/// Shared log methods for OpenTelemetry instrumentation classes.
class OpenTelemetryLog {
  OpenTelemetryLog();

  static void operationException(Logger logger, Exception error, ) {
    // TODO: implement OperationException
    // C#: [LoggerMessage(
    throw UnimplementedError('OperationException not implemented');
  }

  /// Stamps the operation error tag/status on `activity` and logs the
  /// exception.
  ///
  /// Remarks: No-op when `error` is `null`.
  static void recordOperationError(Activity? activity, Logger? logger, Exception? error, ) {
    if (error == null) {
      return;
    }
    _ = activity?
            .addTag(OpenTelemetryConsts.error.type, error.getType().fullName)
            .setStatus(ActivityStatusCode.error, error.message);
    if (logger != null) {
      operationException(logger, error);
    }
  }
}
