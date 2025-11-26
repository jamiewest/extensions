import 'dart:async';
import 'dart:collection';

import '../cache_entry.dart';
import '../cache_item_priority.dart';
import '../eviction_reason.dart';
import '../memory_cache.dart';
import '../memory_cache_options.dart';
import '../memory_cache_statistics.dart';
import 'cache_entry_internal.dart';

/// Implementation of [IMemoryCache].
class MemoryCache implements IMemoryCache {
  MemoryCache(this._options) {
    _startExpirationScan();
  }

  final MemoryCacheOptions _options;
  final Map<Object, CacheEntryInternal> _entries =
      HashMap<Object, CacheEntryInternal>();
  Timer? _expirationTimer;

  // Statistics tracking
  int _hitCount = 0;
  int _missCount = 0;
  int _currentSize = 0;

  @override
  bool containsKey(Object key) => _entries.containsKey(key);

  @override
  bool tryGetValue<T>(Object key, void Function(T? value) setValue) {
    final entry = _entries[key];

    if (entry == null) {
      if (_options.trackStatistics) {
        _missCount++;
      }
      setValue(null);
      return false;
    }

    // Check if expired
    if (entry.isExpired) {
      removeEntry(key, EvictionReason.expired);
      if (_options.trackStatistics) {
        _missCount++;
      }
      setValue(null);
      return false;
    }

    // Update last accessed for sliding expiration
    entry.updateLastAccessed();

    if (_options.trackStatistics) {
      _hitCount++;
    }

    setValue(entry.value as T?);
    return true;
  }

  @override
  ICacheEntry createEntry(Object key) {
    // Remove existing entry if present
    if (_entries.containsKey(key)) {
      removeEntry(key, EvictionReason.replaced);
    }

    final entry = CacheEntryInternal(
      key,
      removeEntry,
      finalizeEntry,
    );

    // Add to cache immediately - finalization happens later via finalizeEntry
    _entries[key] = entry;

    return entry;
  }

  /// Finalizes an entry after configuration.
  ///
  /// This method should be called after an entry is fully configured
  /// to commit it to the cache with size tracking and compaction.
  void finalizeEntry(CacheEntryInternal entry) {
    entry.commit();

    // Update size tracking
    if (_options.sizeLimit != null && entry.size != null) {
      _currentSize += entry.size!;

      // Check if we need to compact
      if (_currentSize > _options.sizeLimit!) {
        compact(_options.compactionPercentage);
      }
    }
  }

  @override
  void remove(Object key) {
    removeEntry(key, EvictionReason.removed);
  }

  /// Internal remove method with eviction reason.
  void removeEntry(Object key, EvictionReason reason) {
    final entry = _entries.remove(key);
    if (entry != null) {
      // Update size
      if (entry.size != null) {
        _currentSize -= entry.size!;
      }

      // Detach listeners
      entry
        ..detach()

        // Invoke callbacks
        ..invokeEvictionCallbacks(reason);
    }
  }

  @override
  MemoryCacheStatistics? getCurrentStatistics() {
    if (!_options.trackStatistics) {
      return null;
    }

    return MemoryCacheStatistics(
      currentEntryCount: _entries.length,
      currentEstimatedSize: _options.sizeLimit != null ? _currentSize : null,
      totalMisses: _missCount,
      totalHits: _hitCount,
    );
  }

  @override
  void clear() {
    final keys = _entries.keys.toList();
    for (final key in keys) {
      removeEntry(key, EvictionReason.removed);
    }
  }

  @override
  void compact(double percentage) {
    if (percentage < 0.0 || percentage > 1.0) {
      throw ArgumentError.value(
        percentage,
        'percentage',
        'Percentage must be between 0.0 and 1.0',
      );
    }

    final targetRemovalCount = (_entries.length * percentage).ceil();
    if (targetRemovalCount == 0) {
      return;
    }

    // Sort entries by priority (low to high) and then by last accessed
    final sortedEntries = _entries.entries.toList()
      ..sort((a, b) {
        // First by priority
        final priorityCompare = _priorityValue(a.value.priority)
            .compareTo(_priorityValue(b.value.priority));
        if (priorityCompare != 0) {
          return priorityCompare;
        }

        // Then by last accessed (oldest first)
        return a.value.lastAccessed.compareTo(b.value.lastAccessed);
      });

    var removed = 0;
    for (final entry in sortedEntries) {
      if (removed >= targetRemovalCount) {
        break;
      }

      // Don't remove NeverRemove items
      if (entry.value.priority == CacheItemPriority.neverRemove) {
        continue;
      }

      removeEntry(entry.key, EvictionReason.capacity);
      removed++;
    }
  }

  int _priorityValue(CacheItemPriority priority) {
    switch (priority) {
      case CacheItemPriority.low:
        return 0;
      case CacheItemPriority.normal:
        return 1;
      case CacheItemPriority.high:
        return 2;
      case CacheItemPriority.neverRemove:
        return 3;
    }
  }

  void _startExpirationScan() {
    if (_options.expirationScanFrequency == Duration.zero) {
      return;
    }

    _expirationTimer = Timer.periodic(
      _options.expirationScanFrequency,
      (_) => _scanForExpiredItems(),
    );
  }

  void _scanForExpiredItems() {
    final keysToRemove = <Object>[];

    for (final entry in _entries.entries) {
      if (entry.value.isExpired) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      removeEntry(key, EvictionReason.expired);
    }
  }

  /// Disposes the cache and stops the expiration timer.
  void dispose() {
    _expirationTimer?.cancel();
    _expirationTimer = null;
    clear();
  }
}

/// Extension to finalize cache entries after they're configured.
extension CacheEntryCommit on ICacheEntry {
  /// Commits this entry to the cache.
  ///
  /// This should be called after configuring the entry to ensure it's
  /// properly added to the cache with all settings applied.
  void commitToCache() {
    if (this is CacheEntryInternal) {
      final impl = this as CacheEntryInternal;
      impl.onFinalizeEntry(impl);
    }
  }
}
