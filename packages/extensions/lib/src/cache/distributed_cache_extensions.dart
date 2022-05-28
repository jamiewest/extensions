import 'dart:convert';

import '../../primitives.dart';
import 'distributed_cache.dart';
import 'distributed_cache_entry_options.dart';

/// Extension methods for setting data in an [DistributedCache].
extension DistributedCacheExtensions on DistributedCache {
  /// Sets a string in the specified cache with the specified key.
  void setStringSync(
    String key,
    String value, {
    DistributedCacheEntryOptions? options,
    CancellationToken? token,
  }) {
    setSync(
      key,
      utf8.encode(value),
      options: options ?? DistributedCacheEntryOptions(),
      token: token,
    );
  }

  /// Asynchronously sets a string in the specified cache with the
  /// specified key.
  Future<void> setString(
    String key,
    String value, {
    DistributedCacheEntryOptions? options,
    CancellationToken? token,
  }) =>
      set(
        key,
        utf8.encode(value),
        options: options ?? DistributedCacheEntryOptions(),
        token: token,
      );

  /// Gets a string from the specified cache with the specified key.
  String? getStringSync(String key) {
    final data = getSync(key);
    if (data == null) {
      return null;
    }
    return utf8.decode(data, allowMalformed: true);
  }

  /// Asynchronously gets a string from the specified cache with the
  /// specified key.
  Future<String?> getString(String key, {CancellationToken? token}) async {
    final data = await get(key, token: token ?? CancellationToken.none);
    if (data == null) {
      return null;
    }
    return utf8.decode(data, allowMalformed: true);
  }
}
