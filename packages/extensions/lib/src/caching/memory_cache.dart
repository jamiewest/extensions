import '../../caching.dart' show MemoryCacheOptions;
import 'cache_entry.dart';
import 'memory_cache_options.dart' show MemoryCacheOptions;
import 'memory_cache_statistics.dart';

/// Represents a local in-memory cache whose values are not serialized.
abstract class IMemoryCache {
  /// Gets a value indicating whether the cache entry associated with
  /// [key] exists.
  ///
  /// Returns true if the cache contains an entry with the given key.
  bool containsKey(Object key);

  /// Gets the value associated with [key] if it exists.
  ///
  /// Returns the cached value, or null if the key is not found.
  /// Sets [value] to the cached value if found.
  ///
  /// Returns true if the key was found.
  bool tryGetValue<T>(Object key, void Function(T? value) setValue);

  /// Creates or overwrites an entry in the cache.
  ///
  /// Returns an [ICacheEntry] for chaining. The entry is not added to
  /// the cache until it is disposed.
  ///
  /// Example:
  /// ```dart
  /// final entry = cache.createEntry('key')
  ///   ..value = 'value'
  ///   ..absoluteExpirationRelativeToNow = Duration(minutes: 5);
  /// // Entry is added when the entry would naturally be disposed,
  /// // or you can manually commit it by calling a method that uses it
  /// ```
  ICacheEntry createEntry(Object key);

  /// Removes the value associated with [key] from the cache.
  void remove(Object key);

  /// Gets a snapshot of the cache statistics.
  ///
  /// Returns null if statistics tracking is not enabled via
  /// [MemoryCacheOptions.trackStatistics].
  MemoryCacheStatistics? getCurrentStatistics();

  /// Removes all keys and values from the cache.
  void clear();

  /// Performs compaction on the cache by removing [percentage] of entries.
  ///
  /// [percentage] should be a value between 0.0 and 1.0.
  /// Entries are removed based on their priority, with lower priority
  /// entries being removed first.
  void compact(double percentage);
}
