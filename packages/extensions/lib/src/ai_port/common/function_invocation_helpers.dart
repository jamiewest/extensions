import '../chat_completion/function_invoking_chat_client.dart';
import '../realtime/function_invoking_realtime_client_session.dart';

/// Internal helper methods shared between [FunctionInvokingChatClient] and
/// [FunctionInvokingRealtimeClientSession].
class FunctionInvocationHelpers {
  FunctionInvocationHelpers();

  /// Gets a value indicating whether [Current] represents an "invoke_agent" or
  /// "invoke_workflow" span.
  static final bool currentActivityIsInvokeAgent;

  /// Returns `true` if `displayName` equals `operationName` or starts with
  /// `operationName` followed by a space (e.g. "invoke_agent my_agent").
  static bool isActivityDisplayNameMatch(String? displayName, String operationName, ) {
    return displayName?.startsWith(operationName, StringComparison.ordinal) is true &&
        (displayName.length == operationName.length || displayName[operationName.length] == ' ');
  }

  /// Gets the elapsed time since the given timestamp.
  static Duration getElapsedTime(long startingTimestamp) {
    return #if NET
        Stopwatch.getElapsedTime(startingTimestamp);
    #else
        new((long)((Stopwatch.getTimestamp() - startingTimestamp) * ((double)TimeSpan.ticksPerSecond / Stopwatch.frequency)));
  }
}
