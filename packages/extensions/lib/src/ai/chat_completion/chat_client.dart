import '../../system/disposable.dart';
import '../../system/threading/cancellation_token.dart';
import 'chat_message.dart';
import 'chat_options.dart';
import 'chat_response.dart';
import 'chat_response_update.dart';

/// Represents a chat client.
///
/// Applications must consider risks such as prompt injection attacks,
/// data sizes, and the number of messages sent to the underlying
/// provider or returned from it. Unless a specific [ChatClient]
/// implementation explicitly documents safeguards for these concerns,
/// the application is expected to implement appropriate protections.
abstract class ChatClient implements Disposable {
  /// Sends a chat request and returns the complete response.
  Future<ChatResponse> getChatResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  });

  /// Sends a chat request and returns a stream of response updates.
  Stream<ChatResponseUpdate> getStreamingChatResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  });

  /// Gets a service of the specified type.
  T? getService<T>({Object? key}) => null;
}
