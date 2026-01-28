import 'ai_content.dart';

/// Represents a request from the model to invoke a function.
class FunctionCallContent extends AIContent {
  /// Creates a new [FunctionCallContent].
  FunctionCallContent({
    required this.callId,
    required this.name,
    this.arguments,
  });

  /// The unique identifier for this function call.
  final String callId;

  /// The name of the function to invoke.
  final String name;

  /// The arguments to pass to the function.
  final Map<String, Object?>? arguments;

  /// An exception that occurred while parsing the arguments.
  Exception? exception;
}
