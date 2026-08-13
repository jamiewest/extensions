import 'dart:typed_data';

import '../../caching/distributed_cache.dart';
import '../../caching/distributed_cache_entry_options.dart';
import '../../dependency_injection/service_provider_service_extensions.dart';
import 'chat_client_builder.dart';
import 'chat_response.dart';
import 'distributed_caching_chat_client.dart';

/// Provides extensions for adding [DistributedCachingChatClient] to a
/// [ChatClientBuilder] pipeline.
extension DistributedCachingChatClientBuilderExtensions on ChatClientBuilder {
  /// Adds response caching backed by a [DistributedCache].
  ///
  /// When [storage] is omitted, it is resolved from the service provider at
  /// build time. [serializeResponse] and [deserializeResponse] define how a
  /// [ChatResponse] round-trips through the cache's byte storage.
  ChatClientBuilder useDistributedCache({
    DistributedCache? storage,
    required Uint8List Function(ChatResponse response) serializeResponse,
    required ChatResponse Function(Uint8List data) deserializeResponse,
    DistributedCacheEntryOptions? cacheOptions,
    void Function(DistributedCachingChatClient client)? configure,
  }) => useWithServices((inner, services) {
    final client = DistributedCachingChatClient(
      inner,
      storage: storage ?? services.getRequiredService<DistributedCache>(),
      serializeResponse: serializeResponse,
      deserializeResponse: deserializeResponse,
      cacheOptions: cacheOptions,
    );
    configure?.call(client);
    return client;
  });
}
