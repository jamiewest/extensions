import '../../primitives.dart';
import 'cache_item_priority.dart';
import 'memory_cache.dart';
import 'post_eviction_callback_registration.dart';

/// Represents the cache options applied to an entry of the
/// [MemoryCache] instance.
class MemoryCacheEntryOptions {
  /// Gets or sets an absolute expiration date for the cache entry.
  DateTime? absoluteExpiration;
  Duration? _absoluteExpirationRelativeToNow;
  Duration? _slidingExpiration;
  int? _size;

  /// Gets an absolute expiration date, relative to now.
  Duration? get absoluteExpirationRelativeToNow =>
      _absoluteExpirationRelativeToNow;

  /// Sets an absolute expiration date, relative to now.
  set absoluteExpirationRelativeToNow(Duration? value) {
    if (value != null) {
      if (value <= Duration.zero) {
        throw ArgumentError.value(
          value,
          'absoluteExpirationRelativeToNow',
          'The relative expiration value must be positive.',
        );
      }
    }
    _absoluteExpirationRelativeToNow = value;
  }

  /// Gets how long a cache entry can be inactive (e.g. not accessed) before
  /// it will be removed. This will not extend the entry lifetime beyond the
  /// absolute expiration (if set).
  Duration? get slidingExpiration => _slidingExpiration;

  /// Gets or sets how long a cache entry can be inactive (e.g. not accessed)
  /// before it will be removed. This will not extend the entry lifetime beyond
  /// the absolute expiration (if set).
  set slidingExpiration(Duration? value) {
    if (value != null) {
      if (value <= Duration.zero) {
        throw ArgumentError.value(
          value,
          'slidingExpiration',
          'The relative expiration value must be positive.',
        );
      }
    }
    _slidingExpiration = value;
  }

  /// Gets the [ChangeToken] instances which cause the cache entry to expire.
  List<ChangeToken> expirationTokens = <ChangeToken>[];

  /// Gets or sets the priority for keeping the cache entry in the cache during
  /// a memory pressure triggered cleanup. The default is
  /// [CacheItemPriority.normal].
  CacheItemPriority priority = CacheItemPriority.normal;

  /// Gets or sets the callbacks will be fired after the cache entry is
  /// evicted from the cache.
  List<PostEvictionCallbackRegistration> get postEvictionCallbacks =>
      <PostEvictionCallbackRegistration>[];

  /// Gets the size of the cache entry value.
  int? get size => _size;

  /// Sets the size of the cache entry value.
  set size(int? value) {
    if (value != null) {
      if (value < 0) {
        throw ArgumentError.value(
          value,
          'size',
          'value must be non-negative.',
        );
      }
    }
    _size = value;
  }
}
