import 'dart:convert';
import 'dart:typed_data';

import 'distributed_cache.dart';
import 'distributed_cache_entry_options.dart';

/// Extension methods for [IDistributedCache].
extension DistributedCacheExtensions on IDistributedCache {
  /// Sets the value for [key] without options.
  Future<void> setBytes(String key, Uint8List value) {
    return set(key, value);
  }

  /// Gets a string value from the cache with the given [key].
  ///
  /// Returns null if the key is not found.
  /// The value is decoded from UTF-8 bytes.
  Future<String?> getString(String key) async {
    final bytes = await get(key);
    if (bytes == null) {
      return null;
    }
    return utf8.decode(bytes);
  }

  /// Sets a string value in the cache with the given [key].
  ///
  /// The value is encoded as UTF-8 bytes before storage.
  /// [options] can be provided to configure expiration.
  Future<void> setString(
    String key,
    String value, [
    DistributedCacheEntryOptions? options,
  ]) {
    final bytes = Uint8List.fromList(utf8.encode(value));
    return set(key, bytes, options);
  }
}
