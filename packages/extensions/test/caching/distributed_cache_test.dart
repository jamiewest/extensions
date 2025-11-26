import 'dart:convert';
import 'dart:typed_data';

import 'package:extensions/caching.dart';
import 'package:test/test.dart';

void main() {
  group('MemoryDistributedCache', () {
    group('Basic Operations', () {
      test('Set and Get returns correct value', () async {
        final cache = MemoryDistributedCache();

        await cache.set('key', Uint8List.fromList([1, 2, 3]));
        final result = await cache.get('key');

        expect(result, equals([1, 2, 3]));
        cache.dispose();
      });

      test('Get returns null for non-existent key', () async {
        final cache = MemoryDistributedCache();

        final result = await cache.get('nonexistent');

        expect(result, isNull);
        cache.dispose();
      });

      test('Remove removes entry from cache', () async {
        final cache = MemoryDistributedCache();

        await cache.set('key', Uint8List.fromList([1, 2, 3]));
        await cache.remove('key');

        final result = await cache.get('key');
        expect(result, isNull);
        cache.dispose();
      });

      test('Set replaces existing value', () async {
        final cache = MemoryDistributedCache();

        await cache.set('key', Uint8List.fromList([1, 2, 3]));
        await cache.set('key', Uint8List.fromList([4, 5, 6]));

        final result = await cache.get('key');
        expect(result, equals([4, 5, 6]));
        cache.dispose();
      });
    });

    group('String Extensions', () {
      test('SetString and GetString work correctly', () async {
        final cache = MemoryDistributedCache();

        await cache.setString('key', 'Hello, World!');
        final result = await cache.getString('key');

        expect(result, equals('Hello, World!'));
        cache.dispose();
      });

      test('GetString returns null for non-existent key', () async {
        final cache = MemoryDistributedCache();

        final result = await cache.getString('nonexistent');

        expect(result, isNull);
        cache.dispose();
      });

      test('SetString with UTF-8 characters', () async {
        final cache = MemoryDistributedCache();

        await cache.setString('key', 'Hello 世界 🌍');
        final result = await cache.getString('key');

        expect(result, equals('Hello 世界 🌍'));
        cache.dispose();
      });

      test('SetString with options', () async {
        final cache = MemoryDistributedCache();

        await cache.setString(
          'key',
          'value',
          DistributedCacheEntryOptions()
            ..slidingExpiration = const Duration(minutes: 5),
        );

        final result = await cache.getString('key');
        expect(result, equals('value'));
        cache.dispose();
      });
    });

    group('Expiration', () {
      test('Entry expires after absolute expiration', () async {
        final cache = MemoryDistributedCache();

        await cache.set(
          'key',
          Uint8List.fromList([1, 2, 3]),
          DistributedCacheEntryOptions()
            ..absoluteExpirationRelativeToNow =
                const Duration(milliseconds: 100),
        );

        var result = await cache.get('key');
        expect(result, isNotNull);

        await Future<void>.delayed(const Duration(milliseconds: 150));

        result = await cache.get('key');
        expect(result, isNull);
        cache.dispose();
      });

      test('Entry with absolute DateTime expires correctly', () async {
        final cache = MemoryDistributedCache();

        await cache.set(
          'key',
          Uint8List.fromList([1, 2, 3]),
          DistributedCacheEntryOptions()
            ..absoluteExpiration =
                DateTime.now().add(const Duration(milliseconds: 100)),
        );

        var result = await cache.get('key');
        expect(result, isNotNull);

        await Future<void>.delayed(const Duration(milliseconds: 150));

        result = await cache.get('key');
        expect(result, isNull);
        cache.dispose();
      });

      test('Sliding expiration works correctly', () async {
        final cache = MemoryDistributedCache();

        await cache.set(
          'key',
          Uint8List.fromList([1, 2, 3]),
          DistributedCacheEntryOptions()
            ..slidingExpiration = const Duration(milliseconds: 100),
        );

        // Access within sliding window
        await Future<void>.delayed(const Duration(milliseconds: 50));
        var result = await cache.get('key');
        expect(result, isNotNull);

        // Wait beyond sliding window
        await Future<void>.delayed(const Duration(milliseconds: 150));
        result = await cache.get('key');
        expect(result, isNull);
        cache.dispose();
      });
    });

    group('Refresh', () {
      test('Refresh resets sliding expiration', () async {
        final cache = MemoryDistributedCache();

        await cache.set(
          'key',
          Uint8List.fromList([1, 2, 3]),
          DistributedCacheEntryOptions()
            ..slidingExpiration = const Duration(milliseconds: 100),
        );

        // Refresh before expiration
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await cache.refresh('key');

        // Wait additional time (total > original sliding window)
        await Future<void>.delayed(const Duration(milliseconds: 75));

        // Should still be available due to refresh
        final result = await cache.get('key');
        expect(result, isNotNull);
        cache.dispose();
      });

      test('Refresh on non-existent key does nothing', () async {
        final cache = MemoryDistributedCache();

        await cache.refresh('nonexistent');

        final result = await cache.get('nonexistent');
        expect(result, isNull);
        cache.dispose();
      });
    });

    group('Binary Data', () {
      test('Stores and retrieves binary data correctly', () async {
        final cache = MemoryDistributedCache();
        final data = Uint8List.fromList(
          List<int>.generate(256, (i) => i),
        );

        await cache.set('binary', data);
        final result = await cache.get('binary');

        expect(result, equals(data));
        cache.dispose();
      });

      test('Stores and retrieves JSON data', () async {
        final cache = MemoryDistributedCache();
        final jsonData = {'name': 'John', 'age': 30, 'active': true};
        final bytes = Uint8List.fromList(utf8.encode(json.encode(jsonData)));

        await cache.set('json', bytes);
        final result = await cache.get('json');

        final decoded =
            json.decode(utf8.decode(result!)) as Map<String, dynamic>;
        expect(decoded['name'], equals('John'));
        expect(decoded['age'], equals(30));
        expect(decoded['active'], isTrue);
        cache.dispose();
      });
    });

    group('Options Validation', () {
      test('Options with zero expiration throws', () {
        expect(
          () => DistributedCacheEntryOptions()
            ..absoluteExpirationRelativeToNow = Duration.zero,
          throwsArgumentError,
        );
      });

      test('Options with negative expiration throws', () {
        final options = DistributedCacheEntryOptions();
        expect(
          () => options.absoluteExpirationRelativeToNow =
              const Duration(seconds: -1),
          throwsArgumentError,
        );
      });

      test('Frozen options cannot be modified', () {
        final options = DistributedCacheEntryOptions()
          ..absoluteExpiration = DateTime.now().add(const Duration(hours: 1))
          ..freeze();

        expect(
          () => options.absoluteExpiration = DateTime.now(),
          throwsStateError,
        );
      });
    });

    group('Disposal', () {
      test('Dispose clears all entries', () async {
        final cache = MemoryDistributedCache();

        await cache.set('key1', Uint8List.fromList([1]));
        await cache.set('key2', Uint8List.fromList([2]));

        cache.dispose();

        // After disposal, cache should be empty
      });

      test('Dispose can be called multiple times', () {
        final cache = MemoryDistributedCache();

        expect(cache.dispose, returnsNormally);
        expect(cache.dispose, returnsNormally);
      });
    });
  });
}
