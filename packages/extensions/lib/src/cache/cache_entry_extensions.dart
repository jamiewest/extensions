import '../primitives/change_token.dart';
import 'cache_entry.dart';
import 'cache_item_priority.dart';
import 'memory_cache_entry_options.dart';
import 'post_eviction_callback_registration.dart';
import 'post_eviction_delegate.dart';

extension CacheEntryExtensions on CacheEntry {
  /// Sets the priority for keeping the cache entry in the cache during a
  /// memory pressure tokened cleanup.
  CacheEntry setPriority(CacheItemPriority priority) {
    this.priority = priority;
    return this;
  }

  /// Expire the cache entry if the given [ChangeToken] expires.
  CacheEntry addExpirationToken(ChangeToken expirationToken) {
    expirationTokens.add(expirationToken);
    return this;
  }

  /// Sets an absolute expiration time, relative to now.
  CacheEntry setAbsoluteExpirationRelativeToNow(Duration relative) {
    absoluteExpirationRelativeToNow = relative;
    return this;
  }

  /// Sets an absolute expiration date for the cache entry.
  CacheEntry setAbsoluteExpiration(DateTime absolute) {
    absoluteExpiration = absolute;
    return this;
  }

  /// Sets how long the cache entry can be inactive (e.g. not accessed)
  /// before it will be removed. This will not extend the entry lifetime
  /// beyond the absolute expiration (if set).
  CacheEntry setSlidingExpiration(Duration offset) {
    slidingExpiration = offset;
    return this;
  }

  /// The given callback will be fired after the cache entry is evicted
  /// from the cache.
  CacheEntry registerPostEvictionCallback(
    PostEvictionDelegate callback, {
    Object? state,
  }) {
    postEvictionCallbacks.add(
      PostEvictionCallbackRegistration(
        evictionCallback: callback,
        state: state,
      ),
    );
    return this;
  }

  /// Sets the value of the cache entry.
  CacheEntry setValue(Object value) {
    this.value = value;
    return this;
  }

  /// Sets the size of the cache entry value.
  CacheEntry setSize(int size) {
    if (size < 0) {
      throw ArgumentError.value(size, 'size', 'size must be non-negative.');
    }
    this.size = size;
    return this;
  }

  /// Applies the values of an existing [MemoryCacheEntryOptions] to the entry.
  CacheEntry setOptions(MemoryCacheEntryOptions options) {
    absoluteExpiration = options.absoluteExpiration;
    absoluteExpirationRelativeToNow = options.absoluteExpirationRelativeToNow;
    slidingExpiration = options.slidingExpiration;
    priority = options.priority;
    size = options.size;

    for (var expirationToken in options.expirationTokens) {
      addExpirationToken(expirationToken);
    }

    for (var postEvictionCallback in options.postEvictionCallbacks) {
      registerPostEvictionCallback(
        postEvictionCallback.evictionCallback,
        state: postEvictionCallback.state,
      );
    }

    return this;
  }
}
