import 'package:extensions/caching.dart';
import 'package:test/test.dart';

void main() {
  group('MemoryCacheEntryOptions', () {
    test('Default values are correct', () {
      final options = MemoryCacheEntryOptions();

      expect(options.absoluteExpiration, isNull);
      expect(options.absoluteExpirationRelativeToNow, isNull);
      expect(options.slidingExpiration, isNull);
      expect(options.priority, equals(CacheItemPriority.normal));
      expect(options.size, isNull);
    });

    test('Values can be set via constructor', () {
      final now = DateTime.now();
      final options = MemoryCacheEntryOptions(
        absoluteExpiration: now,
        absoluteExpirationRelativeToNow: const Duration(hours: 1),
        slidingExpiration: const Duration(minutes: 30),
        priority: CacheItemPriority.high,
        size: 100,
      );

      expect(options.absoluteExpiration, equals(now));
      expect(
        options.absoluteExpirationRelativeToNow,
        equals(const Duration(hours: 1)),
      );
      expect(options.slidingExpiration, equals(const Duration(minutes: 30)));
      expect(options.priority, equals(CacheItemPriority.high));
      expect(options.size, equals(100));
    });

    test('Zero duration throws ArgumentError', () {
      expect(
        () => MemoryCacheEntryOptions()
          ..absoluteExpirationRelativeToNow = Duration.zero,
        throwsArgumentError,
      );

      expect(
        () => MemoryCacheEntryOptions()..slidingExpiration = Duration.zero,
        throwsArgumentError,
      );
    });

    test('Negative size throws ArgumentError', () {
      expect(
        () => MemoryCacheEntryOptions()..size = -1,
        throwsArgumentError,
      );
    });

    test('ExpirationTokens are lazy initialized', () {
      final options = MemoryCacheEntryOptions();

      expect(options.hasExpirationTokens, isFalse);

      final tokens = options.expirationTokens;

      expect(options.hasExpirationTokens, isTrue);
      expect(tokens, isEmpty);
    });

    test('PostEvictionCallbacks are lazy initialized', () {
      final options = MemoryCacheEntryOptions();

      expect(options.hasPostEvictionCallbacks, isFalse);

      final callbacks = options.postEvictionCallbacks;

      expect(options.hasPostEvictionCallbacks, isTrue);
      expect(callbacks, isEmpty);
    });

    test('Can add expiration tokens', () {
      final options = MemoryCacheEntryOptions();
      final stream = Stream<void>.value(null);

      options.expirationTokens.add(stream);

      expect(options.expirationTokens, contains(stream));
    });

    test('Can add post-eviction callbacks', () {
      final options = MemoryCacheEntryOptions();
      final callback = PostEvictionCallbackRegistration(
        evictionCallback: (key, value, reason, state) {},
      );

      options.postEvictionCallbacks.add(callback);

      expect(options.postEvictionCallbacks, contains(callback));
    });
  });

  group('DistributedCacheEntryOptions', () {
    test('Default values are correct', () {
      final options = DistributedCacheEntryOptions();

      expect(options.absoluteExpiration, isNull);
      expect(options.absoluteExpirationRelativeToNow, isNull);
      expect(options.slidingExpiration, isNull);
    });

    test('Values can be set via constructor', () {
      final now = DateTime.now();
      final options = DistributedCacheEntryOptions(
        absoluteExpiration: now,
        absoluteExpirationRelativeToNow: const Duration(hours: 1),
        slidingExpiration: const Duration(minutes: 30),
      );

      expect(options.absoluteExpiration, equals(now));
      expect(
        options.absoluteExpirationRelativeToNow,
        equals(const Duration(hours: 1)),
      );
      expect(options.slidingExpiration, equals(const Duration(minutes: 30)));
    });

    test('Zero duration throws ArgumentError', () {
      expect(
        () => DistributedCacheEntryOptions()
          ..absoluteExpirationRelativeToNow = Duration.zero,
        throwsArgumentError,
      );

      expect(
        () => DistributedCacheEntryOptions()..slidingExpiration = Duration.zero,
        throwsArgumentError,
      );
    });

    test('Freeze prevents modifications', () {
      final options = DistributedCacheEntryOptions()
        ..absoluteExpiration = DateTime.now()
        ..freeze();

      expect(
        () => options.absoluteExpiration = DateTime.now(),
        throwsStateError,
      );

      expect(
        () =>
            options.absoluteExpirationRelativeToNow = const Duration(hours: 1),
        throwsStateError,
      );

      expect(
        () => options.slidingExpiration = const Duration(minutes: 30),
        throwsStateError,
      );
    });

    test('Can modify before freeze', () {
      final options = DistributedCacheEntryOptions();
      final now = DateTime.now();

      options.absoluteExpiration = now;

      expect(options.absoluteExpiration, equals(now));

      options.freeze();

      expect(
        () => options.absoluteExpiration = DateTime.now(),
        throwsStateError,
      );
    });
  });

  group('MemoryCacheOptions', () {
    test('Default values are correct', () {
      final options = MemoryCacheOptions();

      expect(
        options.expirationScanFrequency,
        equals(const Duration(minutes: 1)),
      );
      expect(options.sizeLimit, isNull);
      expect(options.compactionPercentage, equals(0.05));
      expect(options.trackLinkedCacheEntries, isFalse);
      expect(options.trackStatistics, isFalse);
    });

    test('Values can be set via constructor', () {
      final options = MemoryCacheOptions(
        expirationScanFrequency: const Duration(seconds: 30),
        sizeLimit: 1000,
        compactionPercentage: 0.25,
        trackLinkedCacheEntries: true,
        trackStatistics: true,
      );

      expect(
        options.expirationScanFrequency,
        equals(const Duration(seconds: 30)),
      );
      expect(options.sizeLimit, equals(1000));
      expect(options.compactionPercentage, equals(0.25));
      expect(options.trackLinkedCacheEntries, isTrue);
      expect(options.trackStatistics, isTrue);
    });
  });

  group('CacheItemPriority', () {
    test('Has all expected values', () {
      expect(CacheItemPriority.values, hasLength(4));
      expect(CacheItemPriority.values, contains(CacheItemPriority.low));
      expect(CacheItemPriority.values, contains(CacheItemPriority.normal));
      expect(CacheItemPriority.values, contains(CacheItemPriority.high));
      expect(CacheItemPriority.values, contains(CacheItemPriority.neverRemove));
    });
  });

  group('EvictionReason', () {
    test('Has all expected values', () {
      expect(EvictionReason.values, hasLength(6));
      expect(EvictionReason.values, contains(EvictionReason.none));
      expect(EvictionReason.values, contains(EvictionReason.removed));
      expect(EvictionReason.values, contains(EvictionReason.replaced));
      expect(EvictionReason.values, contains(EvictionReason.expired));
      expect(EvictionReason.values, contains(EvictionReason.tokenExpired));
      expect(EvictionReason.values, contains(EvictionReason.capacity));
    });
  });

  group('MemoryCacheStatistics', () {
    test('Constructor sets all values', () {
      const stats = MemoryCacheStatistics(
        currentEntryCount: 10,
        currentEstimatedSize: 100,
        totalMisses: 5,
        totalHits: 20,
      );

      expect(stats.currentEntryCount, equals(10));
      expect(stats.currentEstimatedSize, equals(100));
      expect(stats.totalMisses, equals(5));
      expect(stats.totalHits, equals(20));
    });

    test('Equality works correctly', () {
      const stats1 = MemoryCacheStatistics(
        currentEntryCount: 10,
        currentEstimatedSize: 100,
        totalMisses: 5,
        totalHits: 20,
      );

      const stats2 = MemoryCacheStatistics(
        currentEntryCount: 10,
        currentEstimatedSize: 100,
        totalMisses: 5,
        totalHits: 20,
      );

      expect(stats1, equals(stats2));
      expect(stats1.hashCode, equals(stats2.hashCode));
    });

    test('toString returns expected format', () {
      const stats = MemoryCacheStatistics(
        currentEntryCount: 10,
        currentEstimatedSize: 100,
        totalMisses: 5,
        totalHits: 20,
      );

      final str = stats.toString();

      expect(str, contains('currentEntryCount: 10'));
      expect(str, contains('currentEstimatedSize: 100'));
      expect(str, contains('totalMisses: 5'));
      expect(str, contains('totalHits: 20'));
    });
  });

  group('PostEvictionCallbackRegistration', () {
    test('Constructor sets callback and state', () {
      void callback(
          Object key, Object? value, EvictionReason reason, Object? state) {}

      final registration = PostEvictionCallbackRegistration(
        evictionCallback: callback,
        state: 'test state',
      );

      expect(registration.evictionCallback, equals(callback));
      expect(registration.state, equals('test state'));
    });

    test('State can be null', () {
      void callback(
          Object key, Object? value, EvictionReason reason, Object? state) {}

      final registration = PostEvictionCallbackRegistration(
        evictionCallback: callback,
      );

      expect(registration.state, isNull);
    });
  });
}
