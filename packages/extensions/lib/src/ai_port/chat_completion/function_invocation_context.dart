import '../abstractions/chat_completion/chat_client.dart';
import '../abstractions/chat_completion/chat_message.dart';
import '../abstractions/chat_completion/chat_options.dart';
import '../abstractions/contents/function_call_content.dart';
import '../abstractions/functions/ai_function.dart';
import '../abstractions/functions/ai_function_arguments.dart';
import 'function_invoking_chat_client.dart';

/// Provides context for an in-flight function invocation.
class FunctionInvocationContext {
  /// Initializes a new instance of the [FunctionInvocationContext] class.
  const FunctionInvocationContext();

  /// A nop function used to allow [Function] to be non-nullable. Default
  /// instances of [FunctionInvocationContext] start with this as the target
  /// function.
  static final AFunction _nopFunction;

  /// Gets or sets the AI function to be invoked.
  AFunction function = _nopFunction;

  /// Gets or sets the arguments associated with this invocation.
  AFunctionArguments arguments;

  /// Gets or sets the function call content information associated with this
  /// invocation.
  FunctionCallContent callContent;

  /// Gets or sets the chat contents associated with the operation that
  /// initiated this function call request.
  List<ChatMessage> messages = Array.Empty<ChatMessage>();

  /// Gets or sets the chat options associated with the operation that initiated
  /// this function call request.
  ChatOptions? options;

  /// Gets or sets the number of this iteration with the underlying client.
  ///
  /// Remarks: The initial request to the client that passes along the chat
  /// contents provided to the [FunctionInvokingChatClient] is iteration 1. If
  /// the client responds with a function call request, the next request to the
  /// client is iteration 2, and so on.
  int iteration;

  /// Gets or sets the index of the function call within the iteration.
  ///
  /// Remarks: The response from the underlying client may include multiple
  /// function call requests. This index indicates the position of the function
  /// call within the iteration.
  int functionCallIndex;

  /// Gets or sets the total number of function call requests within the
  /// iteration.
  ///
  /// Remarks: The response from the underlying client might include multiple
  /// function call requests. This count indicates how many there were.
  int functionCount;

  /// Gets or sets a value indicating whether to terminate the request.
  ///
  /// Remarks: In response to a function call request, the function might be
  /// invoked, its result added to the chat contents, and a new request issued
  /// to the wrapped client. If this property is set to `true`, that subsequent
  /// request will not be issued and instead the loop immediately terminated
  /// rather than continuing until there are no more function call requests in
  /// responses. If multiple function call requests are issued as part of a
  /// single iteration (a single response from the inner [ChatClient]), setting
  /// [Terminate] to `true` may also prevent subsequent requests within that
  /// same iteration from being processed.
  bool terminate;

  /// Gets or sets a value indicating whether the function invocation is
  /// occurring as part of a [CancellationToken)] call as opposed to a
  /// [CancellationToken)] call.
  bool isStreaming;
}
