import 'package:extensions/annotations.dart';

import '../../system/threading/cancellation_token.dart';
import 'chat_client.dart';
import 'chat_message.dart';
import 'chat_options.dart';
import 'chat_response.dart';
import 'chat_response_update.dart';
import 'chat_role.dart';

/// Convenience extension methods on [ChatClient].
@Source(
  name: 'ChatClientExtensions.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/ChatCompletion/',
  commit: 'b19cf2050a0787de2c82edbc06d62ba6d27abc2c',
)
extension ChatClientExtensions on ChatClient {
  /// Sends a single user text message and returns the response.
  Future<ChatResponse> getChatResponseFromText(
    String message, {
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      getResponse(
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
      getResponse(
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
      getStreamingResponse(
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
      getStreamingResponse(
        messages: [message],
        options: options,
        cancellationToken: cancellationToken,
      );
}
