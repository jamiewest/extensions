import 'dart:typed_data';

import 'distributed_cache_entry_options.dart';

/// Represents a distributed cache of serialized values.
abstract class IDistributedCache {
  /// Gets a value with the given [key].
  ///
  /// Returns the cached value as bytes, or null if not found.
  Future<Uint8List?> get(String key);

  /// Sets a value with the given [key].
  ///
  /// [key] must not be null.
  /// [value] must not be null.
  /// [options] can be provided to configure expiration.
  Future<void> set(
    String key,
    Uint8List value, [
    DistributedCacheEntryOptions? options,
  ]);

  /// Refreshes a value in the cache based on its key, resetting its
  /// sliding expiration timeout (if any).
  ///
  /// This does nothing if the key is not found.
  Future<void> refresh(String key);

  /// Removes the value with the given [key].
  Future<void> remove(String key);
}
