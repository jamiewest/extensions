import 'dart:async';

import '../cache_entry.dart';
import '../cache_item_priority.dart';
import '../eviction_reason.dart';
import '../post_eviction_callback_registration.dart';

/// Callback type for removing entries.
typedef RemoveEntryCallback = void Function(Object key, EvictionReason reason);

/// Callback type for finalizing entries.
typedef FinalizeEntryCallback = void Function(CacheEntryInternal entry);

/// Internal implementation of [ICacheEntry].
class CacheEntryInternal implements ICacheEntry {
  CacheEntryInternal(
    this.key,
    this.onRemoveEntry,
    this.onFinalizeEntry,
  );

  @override
  final Object key;

  final RemoveEntryCallback onRemoveEntry;
  final FinalizeEntryCallback onFinalizeEntry;

  Object? _value;
  DateTime? _absoluteExpiration;
  Duration? _absoluteExpirationRelativeToNow;
  Duration? _slidingExpiration;
  CacheItemPriority _priority = CacheItemPriority.normal;
  int? _size;
  List<Stream<void>>? _expirationTokens;
  List<StreamSubscription<void>>? _expirationSubscriptions;
  List<PostEvictionCallbackRegistration>? _postEvictionCallbacks;

  DateTime? _lastAccessed;
  bool _isCommitted = false;

  @override
  Object? get value => _value;

  @override
  set value(Object? val) => _value = val;

  @override
  DateTime? get absoluteExpiration => _absoluteExpiration;

  @override
  set absoluteExpiration(DateTime? val) => _absoluteExpiration = val;

  @override
  Duration? get absoluteExpirationRelativeToNow =>
      _absoluteExpirationRelativeToNow;

  @override
  set absoluteExpirationRelativeToNow(Duration? val) {
    if (val != null && !val.isNegative && val == Duration.zero) {
      throw ArgumentError.value(
        val,
        'absoluteExpirationRelativeToNow',
        'The relative expiration value must be positive.',
      );
    }
    _absoluteExpirationRelativeToNow = val;
  }

  @override
  Duration? get slidingExpiration => _slidingExpiration;

  @override
  set slidingExpiration(Duration? val) {
    if (val != null && !val.isNegative && val == Duration.zero) {
      throw ArgumentError.value(
        val,
        'slidingExpiration',
        'The sliding expiration value must be positive.',
      );
    }
    _slidingExpiration = val;
  }

  @override
  CacheItemPriority get priority => _priority;

  @override
  set priority(CacheItemPriority val) => _priority = val;

  @override
  int? get size => _size;

  @override
  set size(int? val) {
    if (val != null && val < 0) {
      throw ArgumentError.value(
        val,
        'size',
        'The size value must be non-negative.',
      );
    }
    _size = val;
  }

  @override
  List<Stream<void>> get expirationTokens =>
      _expirationTokens ??= <Stream<void>>[];

  @override
  List<PostEvictionCallbackRegistration> get postEvictionCallbacks =>
      _postEvictionCallbacks ??= <PostEvictionCallbackRegistration>[];

  DateTime get lastAccessed => _lastAccessed ?? DateTime.now();

  /// Updates the last accessed time to now.
  void updateLastAccessed() {
    _lastAccessed = DateTime.now();
  }

  /// Checks if the entry has expired.
  bool get isExpired {
    final now = DateTime.now();

    // Check absolute expiration
    if (_absoluteExpiration != null && now.isAfter(_absoluteExpiration!)) {
      return true;
    }

    // Check sliding expiration
    if (_slidingExpiration != null && _lastAccessed != null) {
      final expirationTime = _lastAccessed!.add(_slidingExpiration!);
      if (now.isAfter(expirationTime)) {
        return true;
      }
    }

    return false;
  }

  /// Calculates the absolute expiration time.
  DateTime? calculateAbsoluteExpiration() {
    if (_absoluteExpirationRelativeToNow != null) {
      return DateTime.now().add(_absoluteExpirationRelativeToNow!);
    }
    return _absoluteExpiration;
  }

  /// Commits the entry to the cache and sets up expiration token monitoring.
  void commit() {
    if (_isCommitted) {
      return;
    }

    _isCommitted = true;
    _lastAccessed = DateTime.now();

    // Apply relative absolute expiration
    if (_absoluteExpirationRelativeToNow != null) {
      _absoluteExpiration = calculateAbsoluteExpiration();
    }

    // Set up expiration token listeners
    if (_expirationTokens != null && _expirationTokens!.isNotEmpty) {
      _expirationSubscriptions = <StreamSubscription<void>>[];
      for (final token in _expirationTokens!) {
        final subscription = token.listen(
          (_) => onRemoveEntry(key, EvictionReason.tokenExpired),
        );
        _expirationSubscriptions!.add(subscription);
      }
    }
  }

  /// Detaches expiration token listeners.
  void detach() {
    if (_expirationSubscriptions != null) {
      for (final subscription in _expirationSubscriptions!) {
        subscription.cancel();
      }
      _expirationSubscriptions = null;
    }
  }

  /// Invokes post-eviction callbacks.
  void invokeEvictionCallbacks(EvictionReason reason) {
    if (_postEvictionCallbacks != null && _postEvictionCallbacks!.isNotEmpty) {
      // Execute callbacks asynchronously to avoid blocking
      Future.microtask(() {
        for (final registration in _postEvictionCallbacks!) {
          try {
            registration.evictionCallback(
              key,
              _value,
              reason,
              registration.state,
            );
          } catch (e) {
            // Swallow exceptions to prevent callback failures from crashing
            // In a production system, you might want to log this
          }
        }
      });
    }
  }
}
