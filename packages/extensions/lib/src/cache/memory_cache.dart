import 'package:extensions/src/options/options.dart';

import '../../primitives.dart';
import '../logging/logger.dart';
import '../logging/logger_factory.dart';
import 'cache_entry.dart';
import 'memory_cache_options.dart';
import 'system_clock.dart';

/// Represents a local in-memory cache whose values are not serialized.
abstract class MemoryCache extends Disposable {
  /// Gets the item associated with this key if present.
  Object? get(Object key);

  /// Create or overwrite an entry in the cache.
  CacheEntry createEntry(Object key);

  /// Removes the object associated with the given key.
  void remove(Object key);
}

class _MemoryCache implements MemoryCache {
  late Logger _logger;

  _MemoryCache({
    required Options<MemoryCacheOptions> optionsAccessor,
    LoggerFactory? loggerFactory,
  });

  @override
  CacheEntry createEntry(Object key) {
    throw UnimplementedError();
  }

  @override
  void dispose() {}

  @override
  Object? get(Object key) {
    throw UnimplementedError();
  }

  @override
  void remove(Object key) {}

  /// Removes all keys and values from the cache.
  void clear() {}

  void _entryExpired(CacheEntry entry) {}

  void _startScanForExpiredItemsIfNeeded(Duration utcNow) {}

  static void _scanForExpiredItems(MemoryCache cache) {}
}
