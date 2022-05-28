import 'cache_entry.dart';
import 'memory_cache.dart';

typedef CacheEntryFactory = TItem Function<TItem>(CacheEntry entry);
typedef CacheEntryAsyncFactory = Future<TItem> Function<TItem>(
    CacheEntry entry);

extension CacheExtensions on MemoryCache {
  TItem? get<TItem>(Object key) {
    final value = get(key);
    return value as TItem;
  }

  TItem set<TItem>(Object key, TItem value) {
    createEntry(key).value = value;
    return value;
  }

  TItem? getOrCreateSync<TItem>(
    Object key,
    CacheEntryFactory factory,
  ) {
    var result = get(key);
    if (result == null) {
      final entry = createEntry(key);
      result = factory(entry);
      entry.value = result;
    }
    return result as TItem;
  }

  Future<TItem?> getOrCreate<TItem>(
    Object key,
    CacheEntryAsyncFactory factory,
  ) async {
    var result = get(key);
    if (result == null) {
      final entry = createEntry(key);
      result = await factory(entry);
      entry.value = result;
    }
    return result as TItem;
  }
}
