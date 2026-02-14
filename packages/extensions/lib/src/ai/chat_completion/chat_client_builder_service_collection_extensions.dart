import 'package:extensions/annotations.dart';

import '../../dependency_injection/service_collection.dart';
import '../../dependency_injection/service_lifetime.dart';
import '../../dependency_injection/service_provider.dart';
import 'chat_client.dart';
import 'chat_client_builder.dart';

typedef InnerClientFactory = ChatClient Function(ServiceProvider services);

/// Provides extension methods for working with [ChatClient] in the context of
/// [ChatClientBuilder].
@Source(
  name: 'ChatClientBuilderServiceCollectionExtensions.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI/ChatCompletion/',
  commit: '84d09b794d994435568adcbb85a981143d4f15cb',
)
extension ChatClientBuilderServiceCollectionExtensions on ServiceCollection {
  /// Creates a new [ChatClientBuilder] using [innerClient] as its inner client.
  ChatClientBuilder addChatClient(
    InnerClientFactory innerClientFactory, [
    ServiceLifetime lifetime = ServiceLifetime.singleton,
  ]) {
    final builder = ChatClientBuilder.fromFactory(innerClientFactory);
    return builder;
  }
}
