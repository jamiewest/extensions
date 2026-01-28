import '../function_call_content.dart';
import '../functions/ai_function.dart';
import 'chat_message.dart';

/// Provides context for a function invocation within a chat client pipeline.
///
/// This is used by [FunctionInvokingChatClient] to provide information
/// about the current invocation to filters and handlers.
class FunctionInvocationContext {
  /// Creates a new [FunctionInvocationContext].
  FunctionInvocationContext({
    required this.message,
    required this.callContent,
    required this.function_,
    required this.iteration,
    required this.functionCallIndex,
    required this.functionCount,
  });

  /// The chat message containing the function call.
  final ChatMessage message;

  /// The function call content from the model.
  final FunctionCallContent callContent;

  /// The [AIFunction] being invoked.
  final AIFunction function_;

  /// The current iteration of the function-calling loop.
  final int iteration;

  /// The index of this function call within the current iteration.
  final int functionCallIndex;

  /// The total number of function calls in the current iteration.
  final int functionCount;

  /// The result of the function invocation.
  ///
  /// Set by the function invoker after the function completes.
  Object? result;

  /// The exception that occurred during invocation, if any.
  Object? exception;

  /// Whether to terminate the function invocation loop after this call.
  bool terminate = false;
}
