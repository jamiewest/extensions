import '../../dependency_injection/service_provider.dart';
import 'chat_client_builder_service_collection_extensions.dart';
import 'chat_client.dart';
import '../empty_service_provider.dart';

/// Builds a pipeline of chat client middleware.
///
/// The pipeline is composed by calling [use] one or more times, then
/// calling [build] to produce the final [ChatClient]. Middleware
/// factories are applied in reverse order so that the first call to
/// [use] produces the outermost wrapper.
class ChatClientBuilder {
  late final InnerClientFactory _innerClientFactory;

  ChatClientBuilder._(InnerClientFactory innerClientFactory)
      : _innerClientFactory = innerClientFactory;

  /// Creates a new [ChatClientBuilder] wrapping [innerClient].
  ChatClientBuilder(ChatClient innerClient) {
    _innerClientFactory = (services) => innerClient;
  }

  /// Creates a new [ChatClientBuilder] from a factory function.
  factory ChatClientBuilder.fromFactory(
          InnerClientFactory innerClientFactory) =>
      ChatClientBuilder._(innerClientFactory);

  final List<ChatClient Function(ChatClient)> _factories = [];

  /// Adds a middleware factory to the pipeline.
  ///
  /// The [factory] receives the next client in the pipeline
  /// and returns a new [ChatClient] that wraps it.
  ChatClientBuilder use(ChatClient Function(ChatClient) factory) {
    _factories.add(factory);
    return this;
  }

  /// Builds the pipeline and returns the outermost [ChatClient].
  ChatClient build([ServiceProvider? services]) {
    services ??= EmptyServiceProvider.instance;

    var client = _innerClientFactory(services);
    for (var i = _factories.length - 1; i >= 0; i--) {
      client = _factories[i](client);
    }
    return client;
  }
}
