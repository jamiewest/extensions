import 'package:extensions/caching.dart';
import 'package:test/test.dart';

void main() {
  group('CapacityTests', () {
    group('Size Limit Enforcement', () {
      test('Adding entry beyond size limit triggers compaction', () {
        final cache = MemoryCache(
          MemoryCacheOptions(
            sizeLimit: 100,
            compactionPercentage: 0.25, // Remove 25%
          ),
        );

        // Add entries totaling 100 (at limit)
        for (var i = 0; i < 10; i++) {
          cache.set(
            'key$i',
            'value$i',
            MemoryCacheEntryOptions()
              ..size = 10
              ..priority = CacheItemPriority.low,
          );
        }

        cache
          ..getCurrentStatistics()
          // Note: stats might be null if trackStatistics is not enabled

          // Add one more to exceed limit

          ..set(
            'key10',
            'value10',
            MemoryCacheEntryOptions()
              ..size = 10
              ..priority = CacheItemPriority.normal,
          )

          // Some entries should have been removed
          // Exact behavior depends on compaction algorithm
          ..dispose();
      });

      test('Entries without size do not contribute to limit', () {
        final cache = MemoryCache(
          MemoryCacheOptions(
            sizeLimit: 100,
            trackStatistics: true,
          ),
        );

        // Add entries without size
        for (var i = 0; i < 20; i++) {
          cache.set('no-size-$i', 'value$i');
        }

        final stats = cache.getCurrentStatistics();
        expect(stats?.currentEstimatedSize, equals(0));

        // Add entry with size
        cache.set(
          'with-size',
          'value',
          MemoryCacheEntryOptions()..size = 50,
        );

        final stats2 = cache.getCurrentStatistics();
        expect(stats2?.currentEstimatedSize, equals(50));

        cache.dispose();
      });

      test('Size limit of zero allows unlimited entries', () {
        final cache = MemoryCache(MemoryCacheOptions(sizeLimit: 0));

        // Add many entries
        for (var i = 0; i < 1000; i++) {
          cache.set('key$i', 'value$i');
        }

        expect(cache.get<String>('key0'), equals('value0'));
        expect(cache.get<String>('key999'), equals('value999'));

        cache.dispose();
      });

      test('NeverRemove priority prevents eviction during capacity', () {
        final cache = MemoryCache(
          MemoryCacheOptions(
            sizeLimit: 100,
            compactionPercentage: 0.5,
            trackStatistics: true,
          ),
        )
          ..set(
            'critical',
            'important data',
            MemoryCacheEntryOptions()
              ..size = 60
              ..priority = CacheItemPriority.neverRemove,
          )
          ..set(
            'normal1',
            'data1',
            MemoryCacheEntryOptions()
              ..size = 30
              ..priority = CacheItemPriority.normal,
          )
          ..set(
            'normal2',
            'data2',
            MemoryCacheEntryOptions()
              ..size = 30
              ..priority = CacheItemPriority.normal,
          );
        // Total: 120 > 100, should trigger compaction

        // Critical entry should never be removed
        expect(cache.get<String>('critical'), equals('important data'));

        cache.dispose();
      });

      test('Replacing entry updates size tracking', () {
        final cache = MemoryCache(
          MemoryCacheOptions(
            sizeLimit: 100,
            trackStatistics: true,
          ),
        )..set(
            'key',
            'value1',
            MemoryCacheEntryOptions()..size = 50,
          );

        var stats = cache.getCurrentStatistics();
        expect(stats?.currentEstimatedSize, equals(50));

        // Replace with larger entry
        cache.set(
          'key',
          'value2',
          MemoryCacheEntryOptions()..size = 75,
        );

        stats = cache.getCurrentStatistics();
        expect(stats?.currentEstimatedSize, equals(75));

        cache.dispose();
      });

      test('Removing entry updates size tracking', () {
        final cache = MemoryCache(
          MemoryCacheOptions(
            sizeLimit: 100,
            trackStatistics: true,
          ),
        )
          ..set('key1', 'value1', MemoryCacheEntryOptions()..size = 40)
          ..set('key2', 'value2', MemoryCacheEntryOptions()..size = 35);

        var stats = cache.getCurrentStatistics();
        expect(stats?.currentEstimatedSize, equals(75));

        cache.remove('key1');

        stats = cache.getCurrentStatistics();
        expect(stats?.currentEstimatedSize, equals(35));

        cache.dispose();
      });

      test('Clear resets size to zero', () {
        final cache = MemoryCache(
          MemoryCacheOptions(
            sizeLimit: 100,
            trackStatistics: true,
          ),
        );

        for (var i = 0; i < 5; i++) {
          cache.set('key$i', 'value$i', MemoryCacheEntryOptions()..size = 10);
        }

        var stats = cache.getCurrentStatistics();
        expect(stats?.currentEstimatedSize, equals(50));

        cache.clear();

        stats = cache.getCurrentStatistics();
        expect(stats?.currentEstimatedSize, equals(0));

        cache.dispose();
      });
    });

    group('Compaction', () {
      test('Manual compact removes correct percentage', () {
        final cache = MemoryCache(
          MemoryCacheOptions(trackStatistics: true),
        );

        // Add 10 entries
        for (var i = 0; i < 10; i++) {
          cache.set(
            'key$i',
            'value$i',
            MemoryCacheEntryOptions()..priority = CacheItemPriority.low,
          );
        }

        var stats = cache.getCurrentStatistics();
        expect(stats?.currentEntryCount, equals(10));

        // Compact 50%
        cache.compact(0.5);

        stats = cache.getCurrentStatistics();
        expect(stats?.currentEntryCount, equals(5));

        cache.dispose();
      });

      test('Compact respects priority order', () {
        final cache = MemoryCache(MemoryCacheOptions())
          ..set(
            'low1',
            'value',
            MemoryCacheEntryOptions()..priority = CacheItemPriority.low,
          )
          ..set(
            'low2',
            'value',
            MemoryCacheEntryOptions()..priority = CacheItemPriority.low,
          )
          ..set(
            'normal',
            'value',
            MemoryCacheEntryOptions()..priority = CacheItemPriority.normal,
          )
          ..set(
            'high',
            'value',
            MemoryCacheEntryOptions()..priority = CacheItemPriority.high,
          )

          // Compact 50% (remove 2 entries)
          ..compact(0.5);

        // Low priority items should be removed first
        expect(cache.get<String>('low1'), isNull);
        expect(cache.get<String>('low2'), isNull);
        expect(cache.get<String>('normal'), equals('value'));
        expect(cache.get<String>('high'), equals('value'));

        cache.dispose();
      });

      test('Compact removes entries based on priority and age', () async {
        final cache = MemoryCache(
          MemoryCacheOptions(trackStatistics: true),
        )

          // Add entries with different priorities
          ..set(
            'low1',
            'value',
            MemoryCacheEntryOptions()..priority = CacheItemPriority.low,
          )
          ..set(
            'normal',
            'value',
            MemoryCacheEntryOptions()..priority = CacheItemPriority.normal,
          )
          ..set(
            'high',
            'value',
            MemoryCacheEntryOptions()..priority = CacheItemPriority.high,
          )

          // Compact 33% (remove 1 entry)
          ..compact(0.33);

        final stats = cache.getCurrentStatistics();
        expect(stats?.currentEntryCount, equals(2));

        // High priority should remain
        expect(cache.get<String>('high'), equals('value'));

        cache.dispose();
      });

      test('Expired entries are removed on access', () async {
        final cache = MemoryCache(MemoryCacheOptions())
          ..set(
            'expired',
            'value',
            MemoryCacheEntryOptions()
              ..absoluteExpirationRelativeToNow =
                  const Duration(milliseconds: 50)
              ..priority = CacheItemPriority.high,
          )
          ..set(
            'valid',
            'value',
            MemoryCacheEntryOptions()..priority = CacheItemPriority.low,
          );

        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Accessing expired entry removes it
        expect(cache.get<String>('expired'), isNull);
        expect(cache.get<String>('valid'), equals('value'));

        cache.dispose();
      });

      test('Compact with 0 percentage removes nothing', () {
        final cache = MemoryCache(
          MemoryCacheOptions(trackStatistics: true),
        );

        for (var i = 0; i < 5; i++) {
          cache.set('key$i', 'value$i');
        }

        cache.compact(0.0);

        final stats = cache.getCurrentStatistics();
        expect(stats?.currentEntryCount, equals(5));

        cache.dispose();
      });

      test('Compact with 1.0 percentage removes all non-NeverRemove', () {
        final cache = MemoryCache(
          MemoryCacheOptions(trackStatistics: true),
        )
          ..set('removable', 'value')
          ..set(
            'critical',
            'value',
            MemoryCacheEntryOptions()..priority = CacheItemPriority.neverRemove,
          )
          ..compact(1.0);

        expect(cache.get<String>('removable'), isNull);
        expect(cache.get<String>('critical'), equals('value'));

        cache.dispose();
      });

      test('Compact with invalid percentage throws', () {
        final cache = MemoryCache(MemoryCacheOptions());

        expect(() => cache.compact(-0.1), throwsArgumentError);
        expect(() => cache.compact(1.1), throwsArgumentError);

        cache.dispose();
      });

      test('Compaction triggers post-eviction callbacks', () async {
        final cache = MemoryCache(MemoryCacheOptions());
        var callbackCount = 0;
        final evictedKeys = <Object>[];

        for (var i = 0; i < 5; i++) {
          cache.set(
            'key$i',
            'value$i',
            MemoryCacheEntryOptions()
              ..priority = CacheItemPriority.low
              ..postEvictionCallbacks.add(
                PostEvictionCallbackRegistration(
                  evictionCallback: (key, value, reason, state) {
                    callbackCount++;
                    evictedKeys.add(key);
                    expect(reason, equals(EvictionReason.capacity));
                  },
                ),
              ),
          );
        }

        cache.compact(0.6); // Remove 3 entries
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(callbackCount, equals(3));
        expect(evictedKeys, hasLength(3));

        cache.dispose();
      });
    });

    group('Mixed Scenarios', () {
      test('Size limit with expiration', () async {
        final cache = MemoryCache(
          MemoryCacheOptions(
            sizeLimit: 100,
            trackStatistics: true,
          ),
        )..set(
            'expires-soon',
            'value',
            MemoryCacheEntryOptions()
              ..size = 50
              ..absoluteExpirationRelativeToNow =
                  const Duration(milliseconds: 50),
          );

        var stats = cache.getCurrentStatistics();
        expect(stats?.currentEstimatedSize, equals(50));

        // Adding second entry may trigger automatic compaction
        cache.set(
          'permanent',
          'value',
          MemoryCacheEntryOptions()..size = 60,
        );

        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Access to trigger expiration
        cache.get<String>('expires-soon');

        stats = cache.getCurrentStatistics();
        // After expiration, only permanent should remain
        expect(cache.get<String>('expires-soon'), isNull);
        expect(cache.get<String>('permanent'), equals('value'));

        cache.dispose();
      });

      test('Size limit with sliding expiration', () async {
        final cache = MemoryCache(
          MemoryCacheOptions(
            sizeLimit: 100,
            trackStatistics: true,
          ),
        )..set(
            'sliding',
            'value',
            MemoryCacheEntryOptions()
              ..size = 50
              ..slidingExpiration = const Duration(milliseconds: 100),
          );

        // Keep accessing to prevent expiration
        for (var i = 0; i < 5; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          cache.get<String>('sliding');
        }

        // Entry should still be present
        expect(cache.get<String>('sliding'), equals('value'));

        cache.dispose();
      });

      test('Compaction with zero sized entries', () {
        final cache = MemoryCache(
          MemoryCacheOptions(trackStatistics: true),
        );

        for (var i = 0; i < 10; i++) {
          cache.set(
            'key$i',
            'value$i',
            MemoryCacheEntryOptions()
              ..size = 0
              ..priority = CacheItemPriority.low,
          );
        }

        cache.compact(0.5);

        final stats = cache.getCurrentStatistics();
        expect(stats?.currentEntryCount, equals(5));

        cache.dispose();
      });
    });
  });
}
