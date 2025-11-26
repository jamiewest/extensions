/// Provides options for configuring distributed cache entries.
class DistributedCacheEntryOptions {
  /// Creates a new instance of [DistributedCacheEntryOptions].
  DistributedCacheEntryOptions({
    DateTime? absoluteExpiration,
    Duration? absoluteExpirationRelativeToNow,
    Duration? slidingExpiration,
  })  : _absoluteExpiration = absoluteExpiration,
        _absoluteExpirationRelativeToNow = absoluteExpirationRelativeToNow,
        _slidingExpiration = slidingExpiration,
        _isFrozen = false {
    if (absoluteExpirationRelativeToNow != null &&
        (absoluteExpirationRelativeToNow.isNegative ||
            absoluteExpirationRelativeToNow == Duration.zero)) {
      throw ArgumentError.value(
        absoluteExpirationRelativeToNow,
        'absoluteExpirationRelativeToNow',
        'The relative expiration value must be positive.',
      );
    }

    if (slidingExpiration != null &&
        (slidingExpiration.isNegative || slidingExpiration == Duration.zero)) {
      throw ArgumentError.value(
        slidingExpiration,
        'slidingExpiration',
        'The sliding expiration value must be positive.',
      );
    }
  }

  DateTime? _absoluteExpiration;
  Duration? _absoluteExpirationRelativeToNow;
  Duration? _slidingExpiration;
  bool _isFrozen;

  /// Gets or sets the absolute expiration date for the cache entry.
  DateTime? get absoluteExpiration => _absoluteExpiration;
  set absoluteExpiration(DateTime? value) {
    _checkFrozen();
    _absoluteExpiration = value;
  }

  /// Gets or sets the absolute expiration time, relative to now.
  Duration? get absoluteExpirationRelativeToNow =>
      _absoluteExpirationRelativeToNow;
  set absoluteExpirationRelativeToNow(Duration? value) {
    _checkFrozen();
    if (value != null && (value.isNegative || value == Duration.zero)) {
      throw ArgumentError.value(
        value,
        'absoluteExpirationRelativeToNow',
        'The relative expiration value must be positive.',
      );
    }
    _absoluteExpirationRelativeToNow = value;
  }

  /// Gets or sets how long a cache entry can be inactive (not accessed)
  /// before it will be removed. This will not extend the entry lifetime
  /// beyond the absolute expiration (if set).
  Duration? get slidingExpiration => _slidingExpiration;
  set slidingExpiration(Duration? value) {
    _checkFrozen();
    if (value != null && (value.isNegative || value == Duration.zero)) {
      throw ArgumentError.value(
        value,
        'slidingExpiration',
        'The sliding expiration value must be positive.',
      );
    }
    _slidingExpiration = value;
  }

  /// Freezes the options to prevent further modifications.
  ///
  /// After calling this method, any attempt to modify the options
  /// will throw a [StateError].
  void freeze() {
    _isFrozen = true;
  }

  void _checkFrozen() {
    if (_isFrozen) {
      throw StateError(
        'Cannot modify DistributedCacheEntryOptions after it has been frozen.',
      );
    }
  }
}
