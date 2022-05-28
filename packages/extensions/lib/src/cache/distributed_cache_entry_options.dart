import 'distributed_cache.dart';

/// Provides the cache options for an entry in [DistributedCache].
class DistributedCacheEntryOptions {
  /// Gets or sets an absolute expiration date for the cache entry.
  DateTime? absoluteExpiration;
  Duration? _absoluteExpirationRelativeToNow;
  Duration? _slidingExpiration;

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

  /// Sets how long a cache entry can be inactive (e.g. not accessed)
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
}
