import 'distributed_cache_entry_options.dart';

extension MemoryCacheEntryExtensions on DistributedCacheEntryOptions {
  /// Sets an absolute expiration time, relative to now.
  DistributedCacheEntryOptions setAbsoluteExpirationRelativeToNow(
    Duration relative,
  ) {
    absoluteExpirationRelativeToNow = relative;
    return this;
  }

  /// Sets an absolute expiration date for the cache entry.
  DistributedCacheEntryOptions setAbsoluteExpiration(DateTime relative) {
    absoluteExpiration = relative;
    return this;
  }

  /// Sets how long the cache entry can be inactive (e.g. not accessed)
  /// before it will be removed. This will not extend the entry lifetime
  /// beyond the absolute expiration (if set).
  DistributedCacheEntryOptions setSlidingExpiration(Duration offset) {
    slidingExpiration = offset;
    return this;
  }
}
