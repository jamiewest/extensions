import '../../logging/logger.dart';
import '../../logging/logger_extensions.dart';

/// Log messages for function invocation, shared between
/// `FunctionInvokingChatClient` and
/// `FunctionInvokingRealtimeClientSession`.
///
/// Not exported from the `ai` barrel; this mirrors the C# `internal`
/// type. The C# `[LoggerMessage]` source-generated methods collapse into
/// plain static helpers here. Approval-flow messages are not ported
/// because the approval flow itself is not yet ported.
abstract final class FunctionInvocationLogger {
  /// Logs the start of a function invocation.
  static void invoking(Logger? logger, String methodName) =>
      logger?.logDebug('Invoking $methodName.');

  /// Logs the start of a function invocation including its arguments.
  static void invokingSensitive(
    Logger? logger,
    String methodName,
    String arguments,
  ) => logger?.logTrace('Invoking $methodName($arguments).');

  /// Logs the completion of a function invocation.
  static void invocationCompleted(
    Logger? logger,
    String methodName,
    Duration duration,
  ) =>
      logger?.logDebug('$methodName invocation completed. Duration: $duration');

  /// Logs the completion of a function invocation including its result.
  static void invocationCompletedSensitive(
    Logger? logger,
    String methodName,
    Duration duration,
    String result,
  ) => logger?.logTrace(
    '$methodName invocation completed. Duration: $duration. '
    'Result: $result',
  );

  /// Logs the cancellation of a function invocation.
  static void invocationCanceled(Logger? logger, String methodName) =>
      logger?.logDebug('$methodName invocation canceled.');

  /// Logs a failed function invocation.
  static void invocationFailed(
    Logger? logger,
    String methodName,
    Object error,
  ) => logger?.logError('$methodName invocation failed.', error: error);

  /// Logs a function call that references an unknown tool.
  static void functionNotFound(Logger? logger, String functionName) =>
      logger?.logWarning("Function '$functionName' not found.");

  /// Logs a function call that resolved to a declaration-only tool.
  static void nonInvocableFunction(Logger? logger, String functionName) =>
      logger?.logDebug(
        "Function '$functionName' is not invocable (declaration only).",
      );

  /// Logs a function that requested termination of the processing loop.
  static void functionRequestedTermination(
    Logger? logger,
    String functionName,
  ) => logger?.logDebug(
    "Function '$functionName' requested termination of the "
    'processing loop.',
  );
}
