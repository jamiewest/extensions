import 'dart:typed_data';

import '../../caching/distributed_cache.dart';
import '../../caching/distributed_cache_entry_options.dart';
import 'caching_chat_client.dart';
import 'chat_response.dart';

/// A [CachingChatClient] that stores responses in a [DistributedCache].
///
/// Because the port performs no runtime reflection, callers must supply
/// [serializeResponse] and [deserializeResponse] to define how a
/// [ChatResponse] round-trips through the cache's byte storage.
class DistributedCachingChatClient extends CachingChatClient {
  final DistributedCache _storage;
  final DistributedCacheEntryOptions? _cacheOptions;
  final Uint8List Function(ChatResponse response) _serialize;
  final ChatResponse Function(Uint8List data) _deserialize;

  /// Creates a new [DistributedCachingChatClient] backed by [_storage].
  DistributedCachingChatClient(
    super.innerClient, {
    required this._storage,
    required Uint8List Function(ChatResponse response) serializeResponse,
    required ChatResponse Function(Uint8List data) deserializeResponse,
    this._cacheOptions,
  }) : _serialize = serializeResponse,
       _deserialize = deserializeResponse;

  @override
  Future<ChatResponse?> getCachedResponse(String key) async {
    final data = await _storage.get(key);
    if (data == null) {
      return null;
    }
    return _deserialize(data);
  }

  @override
  Future<void> setCachedResponse(String key, ChatResponse response) =>
      _storage.set(key, _serialize(response), _cacheOptions);
}
