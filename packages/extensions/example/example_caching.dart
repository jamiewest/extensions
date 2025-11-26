import 'package:extensions/caching.dart';

void main() async {
  // Example 1: Basic memory cache usage
  print('=== Example 1: Basic Memory Cache ===');
  final cache = MemoryCache(MemoryCacheOptions())

    // Simple set/get
    ..set('name', 'John Doe');
  final name = cache.get<String>('name');
  print('Name: $name');

  // Example 2: Cache with expiration
  print('\n=== Example 2: Cache with Expiration ===');
  cache.set(
    'temp_value',
    'This will expire',
    MemoryCacheEntryOptions()
      ..absoluteExpirationRelativeToNow = const Duration(seconds: 2),
  );
  print('Value before expiration: ${cache.get<String>('temp_value')}');
  await Future<void>.delayed(const Duration(seconds: 3));
  print('Value after expiration: ${cache.get<String>('temp_value')}');

  // Example 3: Get or create pattern
  print('\n=== Example 3: Get or Create Pattern ===');
  var callCount = 0;
  final result1 = cache.getOrCreate<String>('expensive', (entry) {
    callCount++;
    entry.slidingExpiration = const Duration(minutes: 5);
    return 'Expensive computation #$callCount';
  });
  print('First call: $result1');

  final result2 = cache.getOrCreate<String>('expensive', (entry) {
    callCount++;
    entry.slidingExpiration = const Duration(minutes: 5);
    return 'Expensive computation #$callCount';
  });
  print('Second call (cached): $result2');
  print('Factory was called $callCount times');

  // Example 4: Cache with priority and size limits
  print('\n=== Example 4: Priority-based Eviction ===');
  final limitedCache = MemoryCache(
    MemoryCacheOptions(
      sizeLimit: 100,
      compactionPercentage: 0.5,
    ),
  )
    ..set(
      'low',
      'Low priority item',
      MemoryCacheEntryOptions()
        ..priority = CacheItemPriority.low
        ..size = 50,
    )
    ..set(
      'high',
      'High priority item',
      MemoryCacheEntryOptions()
        ..priority = CacheItemPriority.high
        ..size = 60,
    );

  print('Before compaction - Low: ${limitedCache.get('low')}');
  print('Before compaction - High: ${limitedCache.get('high')}');

  // This will trigger compaction (total size = 110 > 100)
  // Low priority items should be removed first

  // Example 5: Distributed cache (in-memory implementation)
  print('\n=== Example 5: Distributed Cache ===');
  final distributedCache = MemoryDistributedCache();

  await distributedCache.setString('user:123', 'Alice');
  final user = await distributedCache.getString('user:123');
  print('User: $user');

  await distributedCache.setString(
    'session:abc',
    'session_data',
    DistributedCacheEntryOptions()
      ..slidingExpiration = const Duration(minutes: 30),
  );

  // Refresh the sliding expiration
  await distributedCache.refresh('session:abc');
  print('Session refreshed');

  // Example 6: Post-eviction callbacks
  print('\n=== Example 6: Eviction Callbacks ===');
  cache.set(
    'tracked',
    'Tracked value',
    MemoryCacheEntryOptions()
      ..absoluteExpirationRelativeToNow = const Duration(seconds: 1)
      ..postEvictionCallbacks.add(
        PostEvictionCallbackRegistration(
          evictionCallback: (key, value, reason, state) {
            print(
              'Item evicted: key=$key, value=$value, reason=$reason',
            );
          },
        ),
      ),
  );

  await Future<void>.delayed(const Duration(seconds: 2));
  print('Waiting for eviction callback...');
  await Future<void>.delayed(const Duration(milliseconds: 100));

  // Example 7: Statistics tracking
  print('\n=== Example 7: Cache Statistics ===');
  final statsCache = MemoryCache(
    MemoryCacheOptions(trackStatistics: true),
  )
    ..set('key1', 'value1')
    ..set('key2', 'value2')
    ..get('key1') // Hit
    ..get('key1') // Hit
    ..get('missing'); // Miss

  final stats = statsCache.getCurrentStatistics();
  if (stats != null) {
    print('Total hits: ${stats.totalHits}');
    print('Total misses: ${stats.totalMisses}');
    print('Current entry count: ${stats.currentEntryCount}');
  }

  // Cleanup
  cache.dispose();
  limitedCache.dispose();
  distributedCache.dispose();
  statsCache.dispose();

  print('\n=== Examples Complete ===');
}
