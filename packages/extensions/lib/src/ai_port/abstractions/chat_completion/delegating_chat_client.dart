import 'chat_client.dart';
import 'chat_message.dart';
import 'chat_options.dart';
import 'chat_response_update.dart';

/// Provides an optional base class for an [ChatClient] that passes through
/// calls to another instance.
///
/// Remarks: This is recommended as a base type when building clients that can
/// be chained around an underlying [ChatClient]. The default implementation
/// simply passes each call to the inner client instance.
class DelegatingChatClient implements ChatClient {
  /// Initializes a new instance of the [DelegatingChatClient] class.
  ///
  /// [innerClient] The wrapped client instance.
  const DelegatingChatClient(ChatClient innerClient)
    : innerClient = Throw.ifNull(innerClient);

  /// Gets the inner [ChatClient].
  final ChatClient innerClient;

  /// Provides a mechanism for releasing unmanaged resources.
  ///
  /// [disposing] `true` if being called from [Dispose]; otherwise, `false`.
  @override
  void dispose({bool? disposing}) {
    if (disposing) {
      innerClient.dispose();
    }
  }

  @override
  Future<ChatResponse> getResponse(
    Iterable<ChatMessage> messages, {
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) {
    return innerClient.getResponseAsync(messages, options, cancellationToken);
  }

  @override
  Stream<ChatResponseUpdate> getStreamingResponse(
    Iterable<ChatMessage> messages, {
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) {
    return innerClient.getStreamingResponseAsync(
      messages,
      options,
      cancellationToken,
    );
  }

  @override
  Object? getService(Type serviceType, {Object? serviceKey}) {
    _ = Throw.ifNull(serviceType);
    return serviceKey == null && serviceType.isInstanceOfType(this)
        ? this
        : innerClient.getService(serviceType, serviceKey);
  }
}
