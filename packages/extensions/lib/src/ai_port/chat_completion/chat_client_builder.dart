import '../../../../../lib/func_typedefs.dart';
import '../abstractions/chat_completion/chat_client.dart';
import '../abstractions/chat_completion/chat_message.dart';
import '../abstractions/chat_completion/chat_options.dart';
import '../abstractions/chat_completion/chat_response_update.dart';
import '../empty_service_provider.dart';

/// A builder for creating pipelines of [ChatClient].
class ChatClientBuilder {
  /// Initializes a new instance of the [ChatClientBuilder] class.
  ///
  /// [innerClient] The inner [ChatClient] that represents the underlying
  /// backend.
  ChatClientBuilder({ChatClient? innerClient = null, Func<ServiceProvider, ChatClient>? innerClientFactory = null, }) : _innerClientFactory = _ => innerClient {
    _ = Throw.ifNull(innerClient);
  }

  final Func<ServiceProvider, ChatClient> _innerClientFactory;

  /// The registered client factory instances.
  List<Func2<ChatClient, ServiceProvider, ChatClient>>? _clientFactories;

  /// Builds an [ChatClient] that represents the entire pipeline. Calls to this
  /// instance will pass through each of the pipeline stages in turn.
  ///
  /// Returns: An instance of [ChatClient] that represents the entire pipeline.
  ///
  /// [services] The [ServiceProvider] that should provide services to the
  /// [ChatClient] instances. If `null`, an empty [ServiceProvider] will be
  /// used.
  ChatClient build({ServiceProvider? services}) {
    services ??= EmptyServiceProvider.instance;
    var chatClient = _innerClientFactory(services);
    if (_clientFactories != null) {
      for (var i = _clientFactories.count - 1; i >= 0; i--) {
        chatClient = _clientFactories[i](chatClient, services);
        if (chatClient == null) {
          Throw.invalidOperationException(
                        'The ${nameof(ChatClientBuilder)} entry at index ${i} returned null. ' +
                        'Ensure that the callbacks passed to ${nameof(Use)} return non-null ${nameof(IChatClient)} instances.');
        }
      }
    }
    return chatClient;
  }

  /// Adds a factory for an intermediate chat client to the chat client
  /// pipeline.
  ///
  /// Returns: The updated [ChatClientBuilder] instance.
  ///
  /// [clientFactory] The client factory function.
  ChatClientBuilder use({Func<ChatClient, ChatClient>? clientFactory, Func4<Iterable<ChatMessage>, ChatOptions?, Func3<Iterable<ChatMessage>, ChatOptions?, CancellationToken, Future>, CancellationToken, Future>? sharedFunc, Func4<Iterable<ChatMessage>, ChatOptions?, ChatClient, CancellationToken, Future<ChatResponse>>? getResponseFunc, Func4<Iterable<ChatMessage>, ChatOptions?, ChatClient, CancellationToken, Stream<ChatResponseUpdate>>? getStreamingResponseFunc, }) {
    _ = Throw.ifNull(clientFactory);
    return use((innerClient, _) => clientFactory(innerClient));
  }
}
