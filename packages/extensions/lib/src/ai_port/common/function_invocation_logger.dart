import '../chat_completion/function_invoking_chat_client.dart';
import '../realtime/function_invoking_realtime_client_session.dart';

/// Internal logger for function invocation operations shared between
/// [FunctionInvokingChatClient] and [FunctionInvokingRealtimeClientSession].
class FunctionInvocationLogger {
  FunctionInvocationLogger();

  static void logInvoking(Logger logger, String methodName) {
    // TODO: implement LogInvoking
    // C#: [LoggerMessage(LogLevel.Debug, "Invoking {MethodName}.", SkipEnabledCheck = true)]
    throw UnimplementedError('LogInvoking not implemented');
  }

  static void logInvokingSensitive(
    Logger logger,
    String methodName,
    String arguments,
  ) {
    // TODO: implement LogInvokingSensitive
    // C#:
    throw UnimplementedError('LogInvokingSensitive not implemented');
  }

  static void logInvocationCompleted(
    Logger logger,
    String methodName,
    Duration duration,
  ) {
    // TODO: implement LogInvocationCompleted
    // C#:
    throw UnimplementedError('LogInvocationCompleted not implemented');
  }

  static void logInvocationCompletedSensitive(
    Logger logger,
    String methodName,
    Duration duration,
    String result,
  ) {
    // TODO: implement LogInvocationCompletedSensitive
    // C#:
    throw UnimplementedError('LogInvocationCompletedSensitive not implemented');
  }

  static void logInvocationCanceled(Logger logger, String methodName) {
    // TODO: implement LogInvocationCanceled
    // C#:
    throw UnimplementedError('LogInvocationCanceled not implemented');
  }

  static void logInvocationFailed(
    Logger logger,
    String methodName,
    Exception error,
  ) {
    // TODO: implement LogInvocationFailed
    // C#:
    throw UnimplementedError('LogInvocationFailed not implemented');
  }

  static void logMaximumIterationsReached(
    Logger logger,
    int maximumIterationsPerRequest,
  ) {
    // TODO: implement LogMaximumIterationsReached
    // C#:
    throw UnimplementedError('LogMaximumIterationsReached not implemented');
  }

  static void logFunctionRequiresApproval(Logger logger, String functionName) {
    // TODO: implement LogFunctionRequiresApproval
    // C#:
    throw UnimplementedError('LogFunctionRequiresApproval not implemented');
  }

  static void logProcessingApprovalResponse(
    Logger logger,
    String functionName,
    bool approved,
  ) {
    // TODO: implement LogProcessingApprovalResponse
    // C#:
    throw UnimplementedError('LogProcessingApprovalResponse not implemented');
  }

  static void logFunctionRejected(
    Logger logger,
    String functionName,
    String? reason,
  ) {
    // TODO: implement LogFunctionRejected
    // C#:
    throw UnimplementedError('LogFunctionRejected not implemented');
  }

  static void logMaxConsecutiveErrorsExceeded(Logger logger, int maxErrors) {
    // TODO: implement LogMaxConsecutiveErrorsExceeded
    // C#:
    throw UnimplementedError('LogMaxConsecutiveErrorsExceeded not implemented');
  }

  static void logFunctionNotFound(Logger logger, String functionName) {
    // TODO: implement LogFunctionNotFound
    // C#:
    throw UnimplementedError('LogFunctionNotFound not implemented');
  }

  static void logNonInvocableFunction(Logger logger, String functionName) {
    // TODO: implement LogNonInvocableFunction
    // C#:
    throw UnimplementedError('LogNonInvocableFunction not implemented');
  }

  static void logFunctionRequestedTermination(
    Logger logger,
    String functionName,
  ) {
    // TODO: implement LogFunctionRequestedTermination
    // C#:
    throw UnimplementedError('LogFunctionRequestedTermination not implemented');
  }
}
