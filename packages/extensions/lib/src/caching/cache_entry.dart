import 'dart:async';

import 'cache_item_priority.dart';
import 'post_eviction_callback_registration.dart';

/// Represents an entry in the [IMemoryCache].
abstract class ICacheEntry {
  /// Gets the key of the cache entry.
  Object get key;

  /// Gets or sets the value of the cache entry.
  Object? get value;
  set value(Object? value);

  /// Gets or sets the absolute expiration date for the cache entry.
  DateTime? get absoluteExpiration;
  set absoluteExpiration(DateTime? value);

  /// Gets or sets the absolute expiration time, relative to now.
  Duration? get absoluteExpirationRelativeToNow;
  set absoluteExpirationRelativeToNow(Duration? value);

  /// Gets or sets how long a cache entry can be inactive (not accessed)
  /// before it will be removed.
  ///
  /// This will not extend the entry lifetime beyond the absolute expiration
  /// (if set).
  Duration? get slidingExpiration;
  set slidingExpiration(Duration? value);

  /// Gets the [Stream]s that cause the cache entry to expire.
  List<Stream<void>> get expirationTokens;

  /// Gets the [PostEvictionCallbackRegistration] instances to call when
  /// the cache entry is evicted.
  List<PostEvictionCallbackRegistration> get postEvictionCallbacks;

  /// Gets or sets the priority for keeping the cache entry in the cache
  /// during a memory pressure triggered cleanup.
  CacheItemPriority get priority;
  set priority(CacheItemPriority value);

  /// Gets or sets the size of the cache entry value.
  int? get size;
  set size(int? value);
}
