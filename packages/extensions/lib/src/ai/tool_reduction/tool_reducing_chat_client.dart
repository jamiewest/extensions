import '../../system/threading/cancellation_token.dart';
import '../chat_completion/chat_message.dart';
import '../chat_completion/chat_options.dart';
import '../chat_completion/chat_response.dart';
import '../chat_completion/chat_response_update.dart';
import '../chat_completion/delegating_chat_client.dart';
import 'tool_reduction_strategy.dart';

/// A [DelegatingChatClient] that applies a [ToolReductionStrategy] to reduce
/// the tool list on each request before passing it to the inner client.
class ToolReducingChatClient extends DelegatingChatClient {
  /// Creates a new [ToolReducingChatClient].
  ToolReducingChatClient(super.innerClient, this._strategy);

  final ToolReductionStrategy _strategy;

  @override
  Future<ChatResponse> getResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    final reducedOptions = await _applyStrategy(
      messages,
      options,
      cancellationToken,
    );
    return super.getResponse(
      messages: messages,
      options: reducedOptions,
      cancellationToken: cancellationToken,
    );
  }

  @override
  Stream<ChatResponseUpdate> getStreamingResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async* {
    final reducedOptions = await _applyStrategy(
      messages,
      options,
      cancellationToken,
    );
    yield* super.getStreamingResponse(
      messages: messages,
      options: reducedOptions,
      cancellationToken: cancellationToken,
    );
  }

  Future<ChatOptions?> _applyStrategy(
    Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  ) async {
    if (options?.tools == null || options!.tools!.isEmpty) return options;
    final reduced = await _strategy.selectToolsForRequest(
      messages,
      options,
      cancellationToken ?? CancellationToken.none,
    );
    final cloned = options.clone();
    cloned.tools = reduced.toList();
    return cloned;
  }
}
