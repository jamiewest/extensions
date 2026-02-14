import 'package:extensions/extensions.dart';

import '../chat_completion/delegating_chat_client.dart';

/// A delegating chat client that applies a tool reduction strategy
/// before invoking the inner client.
///
/// Insert this into a pipeline (typically before function invocation middleware)
/// to automatically reduce the tool list carried on [ChatOptions] for each request.
class ToolReducingChatClient extends DelegatingChatClient {
  final ToolReductionStrategy _strategy;

  /// Initializes a new instance of the [ToolReducingChatClient] class.
  ToolReducingChatClient(super.innerClient, ToolReductionStrategy strategy)
      : _strategy = strategy;

  @override
  Future<ChatResponse> getChatResponse(
      {required Iterable<ChatMessage> messages,
      ChatOptions? options,
      CancellationToken? cancellationToken}) {
    // TODO: implement getChatResponse
    throw UnimplementedError();
  }

  @override
  T? getService<T>({Object? key}) {
    // TODO: implement getService
    throw UnimplementedError();
  }

  @override
  Stream<ChatResponseUpdate> getStreamingChatResponse(
      {required Iterable<ChatMessage> messages,
      ChatOptions? options,
      CancellationToken? cancellationToken}) {
    // TODO: implement getStreamingChatResponse
    throw UnimplementedError();
  }

  @override
  // TODO: implement innerClient
  ChatClient get innerClient => throw UnimplementedError();
}
