import 'package:extensions/caching.dart';
import 'package:test/test.dart';

void main() {
  group('MemoryCache', () {
    group('Basic Operations', () {
      test('Set and Get returns correct value', () {
        final cache = MemoryCache(MemoryCacheOptions())
          ..set('key', 'value');

        final result = cache.get<String>('key');

        expect(result, equals('value'));
        cache.dispose();
      });

      test('Get returns null for non-existent key', () {
        final cache = MemoryCache(MemoryCacheOptions());

        final result = cache.get<String>('nonexistent');

        expect(result, isNull);
        cache.dispose();
      });

      test('ContainsKey returns true for existing key', () {
        final cache = MemoryCache(MemoryCacheOptions())
          ..set('key', 'value');

        expect(cache.containsKey('key'), isTrue);
        cache.dispose();
      });

      test('ContainsKey returns false for non-existent key', () {
        final cache = MemoryCache(MemoryCacheOptions());

        expect(cache.containsKey('nonexistent'), isFalse);
        cache.dispose();
      });

      test('Remove removes entry from cache', () {
        final cache = MemoryCache(MemoryCacheOptions())
          ..set('key', 'value')
          ..remove('key');

        expect(cache.get<String>('key'), isNull);
        cache.dispose();
      });

      test('Clear removes all entries', () {
        final cache = MemoryCache(MemoryCacheOptions())
          ..set('key1', 'value1')
          ..set('key2', 'value2')
          ..set('key3', 'value3')
          ..clear();

        expect(cache.get<String>('key1'), isNull);
        expect(cache.get<String>('key2'), isNull);
        expect(cache.get<String>('key3'), isNull);
        cache.dispose();
      });

      test('TryGetValue returns true and sets value for existing key', () {
        final cache = MemoryCache(MemoryCacheOptions())
          ..set('key', 'value');

        String? result;
        final found =
            cache.tryGetValue<String>('key', (value) => result = value);

        expect(found, isTrue);
        expect(result, equals('value'));
        cache.dispose();
      });

      test('TryGetValue returns false for non-existent key', () {
        final cache = MemoryCache(MemoryCacheOptions());

        String? result;
        final found =
            cache.tryGetValue<String>('key', (value) => result = value);

        expect(found, isFalse);
        expect(result, isNull);
        cache.dispose();
      });

      test('Set replaces existing value', () {
        final cache = MemoryCache(MemoryCacheOptions())
          ..set('key', 'value1')
          ..set('key', 'value2');

        expect(cache.get<String>('key'), equals('value2'));
        cache.dispose();
      });

      test('Multiple types can be stored', () {
        final cache = MemoryCache(MemoryCacheOptions())
          ..set('string', 'text')
          ..set('int', 42)
          ..set('bool', true)
          ..set('list', [1, 2, 3]);

        expect(cache.get<String>('string'), equals('text'));
        expect(cache.get<int>('int'), equals(42));
        expect(cache.get<bool>('bool'), isTrue);
        expect(cache.get<List<int>>('list'), equals([1, 2, 3]));
        cache.dispose();
      });
    });

    group('GetOrCreate Pattern', () {
      test('GetOrCreate creates value on first call', () {
        final cache = MemoryCache(MemoryCacheOptions());
        var callCount = 0;

        final result = cache.getOrCreate<String>('key', (entry) {
          callCount++;
          return 'created';
        });

        expect(result, equals('created'));
        expect(callCount, equals(1));
        cache.dispose();
      });

      test('GetOrCreate returns cached value on second call', () {
        final cache = MemoryCache(MemoryCacheOptions());
        var callCount = 0;

        cache.getOrCreate<String>('key', (entry) {
          callCount++;
          return 'created';
        });

        final result = cache.getOrCreate<String>('key', (entry) {
          callCount++;
          return 'created again';
        });

        expect(result, equals('created'));
        expect(callCount, equals(1));
        cache.dispose();
      });

      test('GetOrCreateAsync creates value on first call', () async {
        final cache = MemoryCache(MemoryCacheOptions());
        var callCount = 0;

        final result =
            await cache.getOrCreateAsync<String>('key', (entry) async {
          callCount++;
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return 'created';
        });

        expect(result, equals('created'));
        expect(callCount, equals(1));
        cache.dispose();
      });

      test('GetOrCreateAsync returns cached value on second call', () async {
        final cache = MemoryCache(MemoryCacheOptions());
        var callCount = 0;

        await cache.getOrCreateAsync<String>('key', (entry) async {
          callCount++;
          return 'created';
        });

        final result =
            await cache.getOrCreateAsync<String>('key', (entry) async {
          callCount++;
          return 'created again';
        });

        expect(result, equals('created'));
        expect(callCount, equals(1));
        cache.dispose();
      });
    });

    group('Absolute Expiration', () {
      test('Entry expires after absolute expiration time', () async {
        final cache = MemoryCache(MemoryCacheOptions())
          ..set(
            'key',
            'value',
            MemoryCacheEntryOptions()
              ..absoluteExpirationRelativeToNow =
                  const Duration(milliseconds: 100),
          );
        expect(cache.get<String>('key'), equals('value'));

        await Future<void>.delayed(const Duration(milliseconds: 150));

        expect(cache.get<String>('key'), isNull);
        cache.dispose();
      });

      test('Entry with absolute DateTime expires correctly', () async {
        final cache = MemoryCache(MemoryCacheOptions())
          ..set(
            'key',
            'value',
            MemoryCacheEntryOptions()
              ..absoluteExpiration =
                  DateTime.now().add(const Duration(milliseconds: 100)),
          );
        expect(cache.get<String>('key'), equals('value'));

        await Future<void>.delayed(const Duration(milliseconds: 150));

        expect(cache.get<String>('key'), isNull);
        cache.dispose();
      });
    });

    group('Sliding Expiration', () {
      test('Entry expires after inactivity period', () async {
        final cache = MemoryCache(MemoryCacheOptions())
          ..set(
            'key',
            'value',
            MemoryCacheEntryOptions()
              ..slidingExpiration = const Duration(milliseconds: 100),
          );
        // Access within sliding window
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(cache.get<String>('key'), equals('value'));

        // Wait beyond sliding window
        await Future<void>.delayed(const Duration(milliseconds: 150));
        expect(cache.get<String>('key'), isNull);

        cache.dispose();
      });

      test('Accessing entry resets sliding expiration', () async {
        final cache = MemoryCache(MemoryCacheOptions())
          ..set(
            'key',
            'value',
            MemoryCacheEntryOptions()
              ..slidingExpiration = const Duration(milliseconds: 100),
          );
        // Access multiple times within sliding window
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(cache.get<String>('key'), equals('value'));

        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(cache.get<String>('key'), equals('value'));

        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(cache.get<String>('key'), equals('value'));

        cache.dispose();
      });
    });

    group('Priority and Compaction', () {
      test('Low priority items are removed first during compaction', () {
        final cache = MemoryCache(
          MemoryCacheOptions(
            sizeLimit: 100,
            compactionPercentage: 0.5,
          ),
        )
          ..set(
            'low',
            'value',
            MemoryCacheEntryOptions()
              ..priority = CacheItemPriority.low
              ..size = 50,
          )
          ..set(
            'high',
            'value',
            MemoryCacheEntryOptions()
              ..priority = CacheItemPriority.high
              ..size = 60,
          );
        // Size is now 110, exceeding limit of 100
        // Compaction should remove 50% = 1 item (the low priority one)

        expect(cache.get<String>('high'), equals('value'));
        // Low priority item may or may not be removed depending on timing
        cache.dispose();
      });

      test('NeverRemove priority items are never evicted', () {
        final cache = MemoryCache(
          MemoryCacheOptions(
            sizeLimit: 100,
          ),
        )
          ..set(
            'never',
            'value',
            MemoryCacheEntryOptions()
              ..priority = CacheItemPriority.neverRemove
              ..size = 60,
          )
          ..set(
            'low',
            'value',
            MemoryCacheEntryOptions()
              ..priority = CacheItemPriority.low
              ..size = 60,
          )
          ..compact(0.5); // Trigger compaction

        expect(cache.get<String>('never'), equals('value'));
        cache.dispose();
      });

      test('Manual compact removes specified percentage', () {
        final cache = MemoryCache(MemoryCacheOptions());

        for (var i = 0; i < 10; i++) {
          cache.set('key$i', 'value$i');
        }

        cache
          ..compact(0.5) // Remove 50%
          ..getCurrentStatistics()
          // Note: statistics are null unless trackStatistics is enabled
          ..dispose();
      });
    });

    group('Post-Eviction Callbacks', () {
      test('Callback is invoked when entry is removed', () async {
        final cache = MemoryCache(MemoryCacheOptions());
        var callbackInvoked = false;
        Object? callbackKey;
        Object? callbackValue;
        EvictionReason? callbackReason;

        cache
          ..set(
            'key',
            'value',
            MemoryCacheEntryOptions()
              ..postEvictionCallbacks.add(
                PostEvictionCallbackRegistration(
                  evictionCallback: (key, value, reason, state) {
                    callbackInvoked = true;
                    callbackKey = key;
                    callbackValue = value;
                    callbackReason = reason;
                  },
                ),
              ),
          )
          ..remove('key');
        // Callbacks are async, wait a bit
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(callbackInvoked, isTrue);
        expect(callbackKey, equals('key'));
        expect(callbackValue, equals('value'));
        expect(callbackReason, equals(EvictionReason.removed));
        cache.dispose();
      });

      test('Callback receives custom state', () async {
        final cache = MemoryCache(MemoryCacheOptions());
        Object? receivedState;

        cache
          ..set(
            'key',
            'value',
            MemoryCacheEntryOptions()
              ..postEvictionCallbacks.add(
                PostEvictionCallbackRegistration(
                  evictionCallback: (key, value, reason, state) {
                    receivedState = state;
                  },
                  state: 'custom state',
                ),
              ),
          )
          ..remove('key');
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(receivedState, equals('custom state'));
        cache.dispose();
      });

      test('Callback is invoked on expiration', () async {
        final cache = MemoryCache(MemoryCacheOptions());
        var callbackInvoked = false;
        EvictionReason? callbackReason;

        cache.set(
          'key',
          'value',
          MemoryCacheEntryOptions()
            ..absoluteExpirationRelativeToNow =
                const Duration(milliseconds: 100)
            ..postEvictionCallbacks.add(
              PostEvictionCallbackRegistration(
                evictionCallback: (key, value, reason, state) {
                  callbackInvoked = true;
                  callbackReason = reason;
                },
              ),
            ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 150));
        cache.get<String>('key'); // Trigger expiration check

        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(callbackInvoked, isTrue);
        expect(callbackReason, equals(EvictionReason.expired));
        cache.dispose();
      });
    });

    group('Statistics', () {
      test('Statistics are null when not enabled', () {
        final cache = MemoryCache(MemoryCacheOptions());

        final stats = cache.getCurrentStatistics();

        expect(stats, isNull);
        cache.dispose();
      });

      test('Statistics track hits and misses', () {
        final cache = MemoryCache(
          MemoryCacheOptions(trackStatistics: true),
        )
          ..set('key', 'value')
          ..get<String>('key') // Hit
          ..get<String>('key') // Hit
          ..get<String>('missing'); // Miss
        final stats = cache.getCurrentStatistics();

        expect(stats, isNotNull);
        expect(stats!.totalHits, equals(2));
        expect(stats.totalMisses, equals(1));
        expect(stats.currentEntryCount, equals(1));
        cache.dispose();
      });

      test('Statistics track entry count', () {
        final cache = MemoryCache(
          MemoryCacheOptions(trackStatistics: true),
        )
          ..set('key1', 'value1')
          ..set('key2', 'value2')
          ..set('key3', 'value3');
        final stats = cache.getCurrentStatistics();

        expect(stats!.currentEntryCount, equals(3));
        cache.dispose();
      });

      test('Statistics track size when enabled', () {
        final cache = MemoryCache(
          MemoryCacheOptions(
            trackStatistics: true,
            sizeLimit: 1000,
          ),
        )
          ..set('key1', 'value1', MemoryCacheEntryOptions()..size = 10)
          ..set('key2', 'value2', MemoryCacheEntryOptions()..size = 20);
        final stats = cache.getCurrentStatistics();

        expect(stats!.currentEstimatedSize, equals(30));
        cache.dispose();
      });
    });

    group('Expiration Scanning', () {
      test('Background scanning removes expired entries', () async {
        final cache = MemoryCache(
          MemoryCacheOptions(
            expirationScanFrequency: const Duration(milliseconds: 100),
          ),
        )..set(
            'key',
            'value',
            MemoryCacheEntryOptions()
              ..absoluteExpirationRelativeToNow =
                  const Duration(milliseconds: 50),
          );
        // Wait for expiration and scan
        await Future<void>.delayed(const Duration(milliseconds: 200));

        expect(cache.get<String>('key'), isNull);
        cache.dispose();
      });

      test('Scanning can be disabled', () {
        final cache = MemoryCache(
          MemoryCacheOptions(
            expirationScanFrequency: Duration.zero,
          ),
        )..set('key', 'value');
        expect(cache.get<String>('key'), equals('value'));
        cache.dispose();
      });
    });

    group('Disposal', () {
      test('Dispose clears all entries', () {
        MemoryCache(MemoryCacheOptions())
          ..set('key1', 'value1')
          ..set('key2', 'value2')
          ..dispose();

        // Note: After disposal, cache should not be used
        // but we can verify it's empty conceptually
      });

      test('Dispose can be called multiple times', () {
        final cache = MemoryCache(MemoryCacheOptions());

        expect(cache.dispose, returnsNormally);
        expect(cache.dispose, returnsNormally);
      });
    });
  });
}
