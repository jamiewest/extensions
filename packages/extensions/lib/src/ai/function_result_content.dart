import 'ai_content.dart';

/// Represents the result of a function call.
class FunctionResultContent extends AIContent {
  /// Creates a new [FunctionResultContent].
  FunctionResultContent({
    required this.callId,
    this.result,
    this.exception,
  });

  /// The call ID corresponding to the function call this is a
  /// result for.
  final String callId;

  /// The result of the function call.
  final Object? result;

  /// An exception that occurred during function execution.
  final Exception? exception;
}
