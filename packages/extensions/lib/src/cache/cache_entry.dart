import '../../primitives.dart';
import 'cache_entry.dart';
import 'cache_item_priority.dart';
import 'eviction_reason.dart';
import 'memory_cache.dart';
import 'post_eviction_callback_registration.dart';

/// Represents an entry in the [MemoryCache] implementation.
abstract class CacheEntry extends Disposable {
  /// Gets the key of the cache entry.
  Object get key;

  /// Gets or set the value of the cache entry.
  Object? value;

  /// Gets or sets an absolute expiration date for the cache entry.
  DateTime? absoluteExpiration;

  /// Gets or sets an absolute expiration time, relative to now.
  Duration? absoluteExpirationRelativeToNow;

  /// Gets or sets how long a cache entry can be inactive (e.g. not accessed)
  /// before it will be removed. This will not extend the entry lifetime beyond
  /// the absolute expiration (if set).
  Duration? slidingExpiration;

  /// Gets the [ChangeToken] instances which cause the cache entry to expire.
  List<ChangeToken> get expirationTokens;

  /// Gets or sets the callbacks will be fired after the cache entry is evicted
  /// from the cache.
  List<PostEvictionCallbackRegistration> get postEvictionCallbacks;

  /// Gets or sets the priority for keeping the cache entry in the cache during
  /// a cleanup. The default is [CacheItemPriority.normal].
  CacheItemPriority priority = CacheItemPriority.normal;

  /// Gets or set the size of the cache entry value.
  int? size;
}

class _CacheEntry implements CacheEntry {
  MemoryCache _cache;

  CacheEntryTokens? _tokens;
  Duration? _absoluteExpirationRelativeToNow;
  Duration? _slidingExpiration;
  int? _size;
  CacheEntry? _previous;
  Object _key;
  Object? _value;
  late CacheEntryState _state;

  _CacheEntry(
    Object key,
    MemoryCache memoryCache,
  )   : _key = key,
        _cache = memoryCache {
    _state = CacheEntryState(CacheItemPriority.normal);
  }

  @override
  Object get key => _key;

  @override
  Object? get value => _value;

  @override
  set value(Object? value) {
    _value = value;
    // _state.isValueSet = true;
  }

  @override
  DateTime? absoluteExpiration;

  @override
  Duration? absoluteExpirationRelativeToNow;

  @override
  CacheItemPriority get priority => _state.priority;

  @override
  set priority(CacheItemPriority value) => _state.priority = value;

  @override
  int? size;

  @override
  Duration? slidingExpiration;

  @override
  void dispose() {}

  @override
  List<ChangeToken> get expirationTokens => throw UnimplementedError();

  @override
  List<PostEvictionCallbackRegistration> get postEvictionCallbacks =>
      throw UnimplementedError();

  EvictionReason get evictionReason => _state.evictionReason!;

  void _setExpired(EvictionReason reason) {
    if (evictionReason == EvictionReason.none) {}
  }
}

class CacheEntryTokens {
  List<ChangeToken>? _expirationTokens;
  List<Disposable>? _expirationTokenRegistrations;
  List<PostEvictionCallbackRegistration>? __postEvictionCallbacks;

  List<ChangeToken> get expirationTokens =>
      _expirationTokens ?? <ChangeToken>[];

  List<PostEvictionCallbackRegistration> get postEvictionCallbacks =>
      __postEvictionCallbacks ?? <PostEvictionCallbackRegistration>[];

  void attachTokens(CacheEntry cacheEntry) {
    if (_expirationTokens != null) {
      for (var i = 0; i < _expirationTokens!.length; i++) {
        var expirationToken = _expirationTokens![i];
        if (expirationToken.activeChangeCallbacks) {
          _expirationTokenRegistrations ??= <Disposable>[];
          var registration = expirationToken.registerChangeCallback(
            (state) {
              var entry = state as CacheEntry;
              //entry.setExpired(EvictionReason.tokenExpired);
            },
          );
        }
      }
    }
  }

  bool checkForExpiredTokens(CacheEntry cacheEntry) {
    if (_expirationTokens != null) {
      for (var i = 0; i < _expirationTokens!.length; i++) {
        var expiredToken = _expirationTokens![i];
        if (expiredToken.hasChanged) {
          //cacheEntry.setExpired(EvictionReason.tokenExpired);
          return true;
        }
      }
    }

    return false;
  }

  bool canPropagateTokens() => _expirationTokens != null;

  void propagateTokens(CacheEntry parentEntry) {
    if (_expirationTokens != null) {
      //parentEntry.getOrCreateTokens();
      for (var expirationToken in _expirationTokens!) {
        //parentEntry.addExpirationToken(expirationToken);
      }
    }
  }

  void detachTokens() {
    if (_expirationTokens != null) {
      var registrations = _expirationTokenRegistrations;
      if (registrations != null) {
        _expirationTokenRegistrations = null;
        for (var i = 0; i < registrations.length; i++) {
          registrations[i].dispose();
        }
      }
    }
  }

  static void invokeCallbacks(CacheEntry entry) {
    //assert(entry._tokens != null);
    //var callbackRegistrations =
  }

  // internal void InvokeEvictionCallbacks(CacheEntry cacheEntry)
  //           {
  //               if (_postEvictionCallbacks != null)
  //               {
  //                   Task.Factory.StartNew(state => InvokeCallbacks((CacheEntry)state!), cacheEntry,
  //                       CancellationToken.None, TaskCreationOptions.DenyChildAttach, TaskScheduler.Default);
  //               }
  //           }

  //           private static void InvokeCallbacks(CacheEntry entry)
  //           {
  //               Debug.Assert(entry._tokens != null);
  //               List<PostEvictionCallbackRegistration>? callbackRegistrations = Interlocked.Exchange(ref entry._tokens._postEvictionCallbacks, null);

  //               if (callbackRegistrations == null)
  //               {
  //                   return;
  //               }

  //               for (int i = 0; i < callbackRegistrations.Count; i++)
  //               {
  //                   PostEvictionCallbackRegistration registration = callbackRegistrations[i];

  //                   try
  //                   {
  //                       registration.EvictionCallback?.Invoke(entry.Key, entry.Value, entry.EvictionReason, registration.State);
  //                   }
  //                   catch (Exception e)
  //                   {
  //                       // This will be invoked on a background thread, don't let it throw.
  //                       entry._cache._logger.LogError(e, "EvictionCallback invoked failed");
  //                   }
  //               }
  //           }
}

class CacheEntryState {
  bool? isDisposed;
  bool? isExpired;
  bool? isValueSet;
  EvictionReason? evictionReason;
  CacheItemPriority priority;

  CacheEntryState(this.priority);
}
