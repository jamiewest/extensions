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
/// Use [MemoryCache] for in-process caching. Store and read values:
///
/// {@example /example/example_caching.dart#memory_cache_basics}
///
/// Entries can expire on a schedule:
///
/// {@example /example/example_caching.dart#cache_expiration}
///
/// `getOrCreate` computes a value only on a miss:
///
/// {@example /example/example_caching.dart#cache_get_or_create}
///
/// ## Distributed Caching
///
/// Use [DistributedCache] for distributed caching across multiple servers:
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
export 'src/caching/memory_cache_service_collection_extensions.dart';
export 'src/caching/memory_cache_statistics.dart';
export 'src/caching/memory_distributed_cache_options.dart';
export 'src/caching/post_eviction_callback_registration.dart';
