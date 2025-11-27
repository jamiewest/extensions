import 'dart:async';

import 'cache_entry.dart';
import 'memory/cache_entry_internal.dart';
import 'memory/memory_cache_impl.dart';
import 'memory_cache.dart';
import 'memory_cache_entry_options.dart';

/// Extension methods for [IMemoryCache].
extension MemoryCacheExtensions on IMemoryCache {
  /// Gets the value associated with [key].
  ///
  /// Returns the cached value, or null if not found.
  T? get<T>(Object key) {
    T? result;
    tryGetValue<T>(key, (value) => result = value);
    return result;
  }

  /// Sets the value for [key].
  ///
  /// Returns [value] for method chaining.
  T set<T>(Object key, T value, [MemoryCacheEntryOptions? options]) {
    final entry = createEntry(key)..value = value;

    if (options != null) {
      entry
        ..absoluteExpiration = options.absoluteExpiration
        ..absoluteExpirationRelativeToNow =
            options.absoluteExpirationRelativeToNow
        ..slidingExpiration = options.slidingExpiration
        ..priority = options.priority
        ..size = options.size;

      if (options.hasExpirationTokens) {
        for (final token in options.expirationTokens) {
          entry.expirationTokens.add(token);
        }
      }

      if (options.hasPostEvictionCallbacks) {
        for (final callback in options.postEvictionCallbacks) {
          entry.postEvictionCallbacks.add(callback);
        }
      }
    }

    // Trigger entry disposal by accessing it
    _commitEntry(entry);

    return value;
  }

  /// Gets the value associated with [key], or creates and caches a new
  /// value using [factory] if not found.
  ///
  /// The [factory] function receives an [ICacheEntry] that can be configured
  /// with expiration settings.
  ///
  /// Example:
  /// ```dart
  /// final value = cache.getOrCreate<String>('key', (entry) {
  ///   entry.slidingExpiration = Duration(minutes: 5);
  ///   return 'computed value';
  /// });
  /// ```
  T getOrCreate<T>(Object key, T Function(ICacheEntry entry) factory) {
    T? result;
    if (tryGetValue<T>(key, (value) => result = value)) {
      return result as T;
    }

    final entry = createEntry(key);
    final value = factory(entry);
    entry.value = value;
    _commitEntry(entry);

    return value;
  }

  /// Async version of [getOrCreate].
  ///
  /// Gets the value associated with [key], or creates and caches a new
  /// value using the async [factory] if not found.
  ///
  /// Example:
  /// ```dart
  /// final value = await cache.getOrCreateAsync<String>('key', (entry) async {
  ///   entry.slidingExpiration = Duration(minutes: 5);
  ///   return await fetchFromApi();
  /// });
  /// ```
  Future<T> getOrCreateAsync<T>(
    Object key,
    Future<T> Function(ICacheEntry entry) factory,
  ) async {
    T? result;
    if (tryGetValue<T>(key, (value) => result = value)) {
      return result as T;
    }

    final entry = createEntry(key);
    final value = await factory(entry);
    entry.value = value;
    _commitEntry(entry);

    return value;
  }

  /// Helper method to commit an entry to the cache.
  ///
  /// In the .NET implementation, this happens when ICacheEntry is disposed.
  /// In Dart, we call this explicitly after configuration.
  void _commitEntry(ICacheEntry entry) {
    if (entry is CacheEntryInternal && this is MemoryCache) {
      (this as MemoryCache).finalizeEntry(entry);
    }
  }
}
