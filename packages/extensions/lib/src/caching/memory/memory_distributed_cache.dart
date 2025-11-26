import 'dart:typed_data';

import '../distributed_cache.dart';
import '../distributed_cache_entry_options.dart';
import '../memory_cache_options.dart';
import 'cache_entry_internal.dart';
import 'memory_cache_impl.dart';

/// An implementation of [IDistributedCache] using an in-memory cache.
///
/// This is useful for testing distributed cache code without requiring
/// an actual distributed cache implementation, or for single-server
/// applications that want to use the [IDistributedCache] interface.
class MemoryDistributedCache implements IDistributedCache {
  /// Creates a new instance of [MemoryDistributedCache].
  MemoryDistributedCache([MemoryCacheOptions? options])
      : _cache = MemoryCache(
          options ??
              MemoryCacheOptions(
                expirationScanFrequency: const Duration(minutes: 1),
              ),
        );

  final MemoryCache _cache;

  @override
  Future<Uint8List?> get(String key) async {
    Uint8List? result;
    _cache.tryGetValue<Uint8List>(key, (value) => result = value);
    return result;
  }

  @override
  Future<void> set(
    String key,
    Uint8List value, [
    DistributedCacheEntryOptions? options,
  ]) async {
    final entry = _cache.createEntry(key)..value = value;

    if (options != null) {
      entry
        ..absoluteExpiration = options.absoluteExpiration
        ..absoluteExpirationRelativeToNow =
            options.absoluteExpirationRelativeToNow
        ..slidingExpiration = options.slidingExpiration;
    }

    // Commit the entry
    if (entry is CacheEntryInternal) {
      _cache.finalizeEntry(entry);
    }
  }

  @override
  Future<void> refresh(String key) async {
    // Access the entry to reset sliding expiration
    _cache.tryGetValue(key, (_) {});
  }

  @override
  Future<void> remove(String key) async {
    _cache.remove(key);
  }

  /// Disposes the underlying memory cache.
  void dispose() {
    _cache.dispose();
  }
}
