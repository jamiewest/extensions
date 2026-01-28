import '../../system/threading/cancellation_token.dart';
import 'chat_client.dart';
import 'chat_message.dart';
import 'chat_options.dart';
import 'chat_response.dart';
import 'chat_response_update.dart';
import 'chat_role.dart';

/// Convenience extension methods on [ChatClient].
extension ChatClientExtensions on ChatClient {
  /// Sends a single user text message and returns the response.
  Future<ChatResponse> getChatResponseFromText(
    String message, {
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      getChatResponse(
        messages: [
          ChatMessage.fromText(ChatRole.user, message),
        ],
        options: options,
        cancellationToken: cancellationToken,
      );

  /// Sends a single message and returns the response.
  Future<ChatResponse> getChatResponseFromMessage(
    ChatMessage message, {
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      getChatResponse(
        messages: [message],
        options: options,
        cancellationToken: cancellationToken,
      );

  /// Sends a single user text message and returns a streaming
  /// response.
  Stream<ChatResponseUpdate> getStreamingChatResponseFromText(
    String message, {
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      getStreamingChatResponse(
        messages: [
          ChatMessage.fromText(ChatRole.user, message),
        ],
        options: options,
        cancellationToken: cancellationToken,
      );

  /// Sends a single message and returns a streaming response.
  Stream<ChatResponseUpdate> getStreamingChatResponseFromMessage(
    ChatMessage message, {
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      getStreamingChatResponse(
        messages: [message],
        options: options,
        cancellationToken: cancellationToken,
      );
}
