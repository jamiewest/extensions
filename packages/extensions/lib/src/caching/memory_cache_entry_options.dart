import 'dart:async';

import 'cache_item_priority.dart';
import 'memory_cache_options.dart';
import 'post_eviction_callback_registration.dart';

/// Provides options for configuring memory cache entries.
class MemoryCacheEntryOptions {
  /// Creates a new instance of [MemoryCacheEntryOptions].
  MemoryCacheEntryOptions({
    this.absoluteExpiration,
    Duration? absoluteExpirationRelativeToNow,
    Duration? slidingExpiration,
    this.priority = CacheItemPriority.normal,
    int? size,
    List<Stream<void>>? expirationTokens,
    List<PostEvictionCallbackRegistration>? postEvictionCallbacks,
  })  : _absoluteExpirationRelativeToNow = absoluteExpirationRelativeToNow,
        _slidingExpiration = slidingExpiration,
        _size = size,
        _expirationTokens = expirationTokens,
        _postEvictionCallbacks = postEvictionCallbacks {
    if (absoluteExpirationRelativeToNow != null &&
        !absoluteExpirationRelativeToNow.isNegative &&
        absoluteExpirationRelativeToNow == Duration.zero) {
      throw ArgumentError.value(
        absoluteExpirationRelativeToNow,
        'absoluteExpirationRelativeToNow',
        'The relative expiration value must be positive.',
      );
    }

    if (slidingExpiration != null &&
        !slidingExpiration.isNegative &&
        slidingExpiration == Duration.zero) {
      throw ArgumentError.value(
        slidingExpiration,
        'slidingExpiration',
        'The sliding expiration value must be positive.',
      );
    }

    if (size != null && size < 0) {
      throw ArgumentError.value(
        size,
        'size',
        'The size value must be non-negative.',
      );
    }
  }

  DateTime? absoluteExpiration;
  Duration? _absoluteExpirationRelativeToNow;
  Duration? _slidingExpiration;
  CacheItemPriority priority;
  int? _size;
  List<Stream<void>>? _expirationTokens;
  List<PostEvictionCallbackRegistration>? _postEvictionCallbacks;

  /// Gets or sets the absolute expiration time, relative to now.
  Duration? get absoluteExpirationRelativeToNow =>
      _absoluteExpirationRelativeToNow;
  set absoluteExpirationRelativeToNow(Duration? value) {
    if (value != null && !value.isNegative && value == Duration.zero) {
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
    if (value != null && !value.isNegative && value == Duration.zero) {
      throw ArgumentError.value(
        value,
        'slidingExpiration',
        'The sliding expiration value must be positive.',
      );
    }
    _slidingExpiration = value;
  }

  /// Gets or sets the size of the cache entry value.
  ///
  /// The size is an arbitrary value defined by the application.
  /// When set, the cache will enforce the [MemoryCacheOptions.sizeLimit]
  /// and remove entries when the total size exceeds the limit.
  int? get size => _size;
  set size(int? value) {
    if (value != null && value < 0) {
      throw ArgumentError.value(
        value,
        'size',
        'The size value must be non-negative.',
      );
    }
    _size = value;
  }

  /// Gets the [Stream]s that cause the cache entry to expire.
  ///
  /// When any stream emits a value, the cache entry will be evicted.
  List<Stream<void>> get expirationTokens =>
      _expirationTokens ??= <Stream<void>>[];

  /// Gets the [PostEvictionCallbackRegistration] instances to call when
  /// the cache entry is evicted.
  List<PostEvictionCallbackRegistration> get postEvictionCallbacks =>
      _postEvictionCallbacks ??= <PostEvictionCallbackRegistration>[];

  /// Helper to check if expiration tokens have been initialized.
  bool get hasExpirationTokens => _expirationTokens != null;

  /// Helper to check if post-eviction callbacks have been initialized.
  bool get hasPostEvictionCallbacks => _postEvictionCallbacks != null;
}
