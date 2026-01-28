import '../../dependency_injection/service_collection.dart';
import '../../dependency_injection/service_lifetime.dart';
import '../../dependency_injection/service_provider.dart';
import 'chat_client_builder.dart';
import 'chat_client.dart';

typedef InnerClientFactory = ChatClient Function(ServiceProvider services);

/// Provides extension methods for registering a [ChatClient] with
/// a [ServiceCollection].
extension ChatClientBuilderServiceCollectionExtensions on ServiceCollection {
  ChatClientBuilder addChatClient(
    InnerClientFactory innerClientFactory, [
    ServiceLifetime lifetime = ServiceLifetime.singleton,
  ]) {
    final builder = ChatClientBuilder.fromFactory(innerClientFactory);
    return builder;
  }
}
