import '../../primitives.dart';
import 'cache_item_priority.dart';
import 'memory_cache_entry_options.dart';
import 'post_eviction_callback_registration.dart';
import 'post_eviction_delegate.dart';

extension MemoryCacheEntryExtensions on MemoryCacheEntryOptions {
  /// Sets the priority for keeping the cache entry in the cache during a
  /// memory pressure tokened cleanup.
  MemoryCacheEntryOptions setPriority(CacheItemPriority priority) {
    this.priority = priority;
    return this;
  }

  /// Sets the size of the cache entry value.
  MemoryCacheEntryOptions setSize(int size) {
    if (size < 0) {
      throw ArgumentError.value(size, 'size', 'size must be non-negative.');
    }
    this.size = size;
    return this;
  }

  /// Expire the cache entry if the given [ChangeToken] expires.
  MemoryCacheEntryOptions addExpirationToken(ChangeToken expirationToken) {
    expirationTokens.add(expirationToken);
    return this;
  }

  /// Sets an absolute expiration time, relative to now.
  MemoryCacheEntryOptions setAbsoluteExpiration(Duration relative) {
    absoluteExpirationRelativeToNow = relative;
    return this;
  }

  /// Sets how long the cache entry can be inactive (e.g. not accessed)
  /// before it will be removed. This will not extend the entry lifetime
  /// beyond the absolute expiration (if set).
  MemoryCacheEntryOptions setSlidingExpiration(Duration offset) {
    slidingExpiration = offset;
    return this;
  }

  /// The given callback will be fired after the cache entry is evicted
  /// from the cache.
  MemoryCacheEntryOptions registerPostEvictionCallback(
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
}
