/// Specifies the reason why a cache entry was evicted.
enum EvictionReason {
  /// The item was not removed from the cache.
  none,

  /// The item was removed from the cache manually.
  removed,

  /// The item was removed from the cache because it was overwritten.
  replaced,

  /// The item was removed from the cache because it expired.
  expired,

  /// The item was removed from the cache because a change token fired.
  tokenExpired,

  /// The item was removed from the cache because it exceeded its capacity.
  capacity,
}
