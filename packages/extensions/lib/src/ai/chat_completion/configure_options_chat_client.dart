import '../../system/threading/cancellation_token.dart';
import 'chat_message.dart';
import 'chat_options.dart';
import 'chat_response.dart';
import 'chat_response_update.dart';
import 'delegating_chat_client.dart';

/// A delegating chat client that applies configuration to [ChatOptions]
/// before each request.
class ConfigureOptionsChatClient extends DelegatingChatClient {
  /// Creates a new [ConfigureOptionsChatClient].
  ///
  /// [configure] is called before each request to modify the options.
  ConfigureOptionsChatClient(
    super.innerClient, {
    required this.configure,
  });

  /// The callback that configures [ChatOptions] before each request.
  final ChatOptions Function(ChatOptions options) configure;

  @override
  Future<ChatResponse> getResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      super.getResponse(
        messages: messages,
        options: configure(options ?? ChatOptions()),
        cancellationToken: cancellationToken,
      );

  @override
  Stream<ChatResponseUpdate> getStreamingResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      super.getStreamingResponse(
        messages: messages,
        options: configure(options ?? ChatOptions()),
        cancellationToken: cancellationToken,
      );
}
