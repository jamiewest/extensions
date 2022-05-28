import '../../primitives.dart';
import 'distributed_cache_entry_options.dart';

/// Represents a distributed cache of serialized values.
abstract class DistributedCache {
  /// Gets a value with the given key.
  List<int>? getSync(String key);

  /// Gets a value with the given key.
  Future<List<int>?> get(
    String key, {
    CancellationToken? token,
  });

  /// Sets a value with the given key.
  void setSync(
    String key,
    List<int> value, {
    DistributedCacheEntryOptions? options,
    CancellationToken? token,
  });

  /// Sets a value with the given key.
  Future<void> set(
    String key,
    List<int> value, {
    DistributedCacheEntryOptions? options,
    CancellationToken? token,
  });

  /// Refreshes a value in the cache based on its key, resetting its sliding
  /// expiration timeout (if any).
  void refreshSync(String key);

  /// Refreshes a value in the cache based on its key, resetting its sliding
  /// expiration timeout (if any).
  Future<void> refresh(
    String key, {
    CancellationToken? token,
  });

  /// Removes the value with the given key.
  void removeSync(String key);

  /// Removes the value with the given key.
  Future<void> remove(
    String key, {
    CancellationToken? token,
  });
}
