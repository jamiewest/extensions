/// Contains classes and abstractions for caching data in memory and
/// distributed systems.
///
/// This library provides a comprehensive caching solution inspired by
/// Microsoft.Extensions.Caching, offering both in-memory and distributed
/// caching capabilities with features like:
///
/// - Multiple expiration strategies (absolute, sliding, change token-based)
/// - Priority-based eviction policies
/// - Size-based capacity management
/// - Post-eviction callbacks
/// - Statistics tracking
/// - Type-safe generic APIs
///
/// ## Memory Caching
///
/// Use [IMemoryCache] for fast, in-memory caching of objects:
///
/// ```dart
/// final cache = MemoryCache(MemoryCacheOptions());
///
/// // Simple set/get
/// cache.set('key', 'value');
/// final value = cache.get<String>('key');
///
/// // With expiration
/// cache.set('key', 'value', MemoryCacheEntryOptions()
///   ..absoluteExpirationRelativeToNow = Duration(minutes: 5));
///
/// // Get or create pattern
/// final data = await cache.getOrCreateAsync<String>('key', (entry) async {
///   entry.slidingExpiration = Duration(minutes: 15);
///   return await fetchDataFromApi();
/// });
/// ```
///
/// ## Distributed Caching
///
/// Use [IDistributedCache] for distributed caching across multiple servers:
///
/// ```dart
/// final cache = MemoryDistributedCache(MemoryDistributedCacheOptions());
///
/// // Store bytes
/// await cache.set('key', utf8.encode('value'));
///
/// // Store strings
/// await cache.setString('key', 'value', DistributedCacheEntryOptions()
///   ..slidingExpiration = Duration(hours: 1));
///
/// // Retrieve data
/// final value = await cache.getString('key');
/// ```
library;

import 'src/caching/distributed_cache.dart';
import 'src/caching/memory_cache.dart';

// Core abstractions
export 'src/caching/cache_entry.dart';
export 'src/caching/cache_item_priority.dart';
export 'src/caching/distributed_cache.dart';
export 'src/caching/distributed_cache_entry_options.dart';
export 'src/caching/distributed_cache_extensions.dart';
export 'src/caching/eviction_reason.dart';
export 'src/caching/memory/memory_cache_impl.dart';
export 'src/caching/memory/memory_distributed_cache.dart';
export 'src/caching/memory_cache.dart';
export 'src/caching/memory_cache_entry_options.dart';
export 'src/caching/memory_cache_extensions.dart';
export 'src/caching/memory_cache_options.dart';
export 'src/caching/memory_cache_statistics.dart';
export 'src/caching/post_eviction_callback_registration.dart';
