import '../../dependency_injection/service_collection.dart';
import '../../dependency_injection/service_descriptor.dart';
import '../../dependency_injection/service_lifetime.dart';
import '../../dependency_injection/service_provider.dart';
import 'chat_client.dart';
import 'chat_client_builder.dart';

typedef InnerClientFactory = ChatClient Function(ServiceProvider services);

/// Provides extension methods for working with [ChatClient] in the context of
/// [ChatClientBuilder].
extension ChatClientBuilderServiceCollectionExtensions on ServiceCollection {
  /// Registers a [ChatClient] in the service collection and returns a
  /// [ChatClientBuilder] for adding middleware to the pipeline.
  ChatClientBuilder addChatClient(
    InnerClientFactory innerClientFactory, [
    ServiceLifetime lifetime = ServiceLifetime.singleton,
  ]) {
    final builder = ChatClientBuilder.fromFactory(innerClientFactory);
    add(switch (lifetime) {
      ServiceLifetime.singleton => ServiceDescriptor.singleton<ChatClient>(
        (sp) => builder.build(sp),
      ),
      ServiceLifetime.scoped => ServiceDescriptor.scoped<ChatClient>(
        (sp) => builder.build(sp),
      ),
      ServiceLifetime.transient => ServiceDescriptor.transient<ChatClient>(
        (sp) => builder.build(sp),
      ),
    });
    return builder;
  }
}
