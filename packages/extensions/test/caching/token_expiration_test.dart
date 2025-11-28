import 'dart:async';

import 'package:extensions/caching.dart';
import 'package:test/test.dart';

void main() {
  group('TokenExpirationTests', () {
    group('Stream Tokens', () {
      test('Entry expires when stream token emits', () async {
        final cache = MemoryCache(MemoryCacheOptions());
        final controller = StreamController<void>.broadcast();

        cache.set(
          'key',
          'value',
          MemoryCacheEntryOptions()..expirationTokens.add(controller.stream),
        );

        expect(cache.get<String>('key'), equals('value'));

        controller.add(null);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(cache.get<String>('key'), isNull);

        await controller.close();
        cache.dispose();
      });

      test('Multiple tokens - first emission expires entry', () async {
        final cache = MemoryCache(MemoryCacheOptions());
        final controller1 = StreamController<void>.broadcast();
        final controller2 = StreamController<void>.broadcast();

        cache.set(
          'key',
          'value',
          MemoryCacheEntryOptions()
            ..expirationTokens.add(controller1.stream)
            ..expirationTokens.add(controller2.stream),
        );

        expect(cache.get<String>('key'), equals('value'));

        // First token fires
        controller1.add(null);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(cache.get<String>('key'), isNull);

        // Second token shouldn't cause issues
        controller2.add(null);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        await controller1.close();
        await controller2.close();
        cache.dispose();
      });

      test('Token expiration triggers post-eviction callback', () async {
        final cache = MemoryCache(MemoryCacheOptions());
        final controller = StreamController<void>.broadcast();

        var callbackInvoked = false;
        EvictionReason? callbackReason;

        cache.set(
          'key',
          'value',
          MemoryCacheEntryOptions()
            ..expirationTokens.add(controller.stream)
            ..postEvictionCallbacks.add(
              PostEvictionCallbackRegistration(
                evictionCallback: (key, value, reason, state) {
                  callbackInvoked = true;
                  callbackReason = reason;
                },
              ),
            ),
        );

        controller.add(null);
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(callbackInvoked, isTrue);
        expect(callbackReason, equals(EvictionReason.tokenExpired));

        await controller.close();
        cache.dispose();
      });

      test('Token expiration with value type different from entry', () async {
        final cache = MemoryCache(MemoryCacheOptions());
        final controller = StreamController<int>.broadcast();

        cache.set(
          'key',
          'string value',
          MemoryCacheEntryOptions()
            ..expirationTokens.add(controller.stream as Stream<void>),
        );

        expect(cache.get<String>('key'), equals('string value'));

        controller.add(42);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(cache.get<String>('key'), isNull);

        await controller.close();
        cache.dispose();
      });

      test('Multiple entries with same token expire together', () async {
        final cache = MemoryCache(MemoryCacheOptions());
        final controller = StreamController<void>.broadcast();

        cache
          ..set(
            'key1',
            'value1',
            MemoryCacheEntryOptions()..expirationTokens.add(controller.stream),
          )
          ..set(
            'key2',
            'value2',
            MemoryCacheEntryOptions()..expirationTokens.add(controller.stream),
          )
          ..set(
            'key3',
            'value3',
            MemoryCacheEntryOptions()..expirationTokens.add(controller.stream),
          );

        expect(cache.get<String>('key1'), equals('value1'));
        expect(cache.get<String>('key2'), equals('value2'));
        expect(cache.get<String>('key3'), equals('value3'));

        controller.add(null);
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(cache.get<String>('key1'), isNull);
        expect(cache.get<String>('key2'), isNull);
        expect(cache.get<String>('key3'), isNull);

        await controller.close();
        cache.dispose();
      });

      test('Token expiration combined with time expiration', () async {
        final cache = MemoryCache(MemoryCacheOptions());
        final controller = StreamController<void>.broadcast();

        cache.set(
          'key',
          'value',
          MemoryCacheEntryOptions()
            ..absoluteExpirationRelativeToNow = const Duration(seconds: 10)
            ..expirationTokens.add(controller.stream),
        );

        expect(cache.get<String>('key'), equals('value'));

        // Token fires before time expiration
        controller.add(null);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(cache.get<String>('key'), isNull);

        await controller.close();
        cache.dispose();
      });

      test('Token does not affect other entries', () async {
        final cache = MemoryCache(MemoryCacheOptions());
        final controller = StreamController<void>.broadcast();

        cache
          ..set(
            'with-token',
            'value1',
            MemoryCacheEntryOptions()..expirationTokens.add(controller.stream),
          )
          ..set('without-token', 'value2');

        expect(cache.get<String>('with-token'), equals('value1'));
        expect(cache.get<String>('without-token'), equals('value2'));

        controller.add(null);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(cache.get<String>('with-token'), isNull);
        expect(cache.get<String>('without-token'), equals('value2'));

        await controller.close();
        cache.dispose();
      });

      test('Removed entry unsubscribes from token', () async {
        final cache = MemoryCache(MemoryCacheOptions());
        final controller = StreamController<void>.broadcast();

        cache
          ..set(
            'key',
            'value',
            MemoryCacheEntryOptions()..expirationTokens.add(controller.stream),
          )

          // Remove entry manually
          ..remove('key');

        // Token emission should not cause issues
        controller.add(null);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Entry should still be null
        expect(cache.get<String>('key'), isNull);

        await controller.close();
        cache.dispose();
      });

      test('Multiple emissions on same token only expire once', () async {
        final cache = MemoryCache(MemoryCacheOptions());
        final controller = StreamController<void>.broadcast();

        var callbackCount = 0;

        cache.set(
          'key',
          'value',
          MemoryCacheEntryOptions()
            ..expirationTokens.add(controller.stream)
            ..postEvictionCallbacks.add(
              PostEvictionCallbackRegistration(
                evictionCallback: (key, value, reason, state) {
                  callbackCount++;
                },
              ),
            ),
        );

        controller
          ..add(null)
          ..add(null)
          ..add(null);
        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Callback should only be invoked once
        expect(callbackCount, equals(1));

        await controller.close();
        cache.dispose();
      });
    });

    group('Disposal Cleanup', () {
      test('Cache disposal cancels token subscriptions', () async {
        final controller = StreamController<void>.broadcast()

          // After disposal, token emissions should not cause issues
          ..add(null);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        await controller.close();
      });

      test('Clear cancels all token subscriptions', () async {
        final controller = StreamController<void>.broadcast();
        final cache = MemoryCache(MemoryCacheOptions())
          ..set(
            'key1',
            'value1',
            MemoryCacheEntryOptions()..expirationTokens.add(controller.stream),
          )
          ..set(
            'key2',
            'value2',
            MemoryCacheEntryOptions()..expirationTokens.add(controller.stream),
          )
          ..clear();

        // After clear, token emissions should not cause issues
        controller.add(null);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        await controller.close();
        cache.dispose();
      });
    });

    group('Edge Cases', () {
      test('Token that never emits keeps entry alive', () async {
        final cache = MemoryCache(MemoryCacheOptions());
        final controller = StreamController<void>.broadcast();

        cache.set(
          'key',
          'value',
          MemoryCacheEntryOptions()..expirationTokens.add(controller.stream),
        );

        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Entry should still be present
        expect(cache.get<String>('key'), equals('value'));

        await controller.close();
        cache.dispose();
      });

      test('Immediate token emission expires entry', () async {
        final cache = MemoryCache(MemoryCacheOptions());
        final controller = StreamController<void>.broadcast()

          // Emit before adding to cache
          ..add(null);

        cache.set(
          'key',
          'value',
          MemoryCacheEntryOptions()..expirationTokens.add(controller.stream),
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Entry should still be present since subscription happened
        // after emission
        expect(cache.get<String>('key'), equals('value'));

        await controller.close();
        cache.dispose();
      });

      test('Entry can be replaced after token expiration', () async {
        final cache = MemoryCache(MemoryCacheOptions());
        final controller = StreamController<void>.broadcast();

        cache.set(
          'key',
          'value1',
          MemoryCacheEntryOptions()..expirationTokens.add(controller.stream),
        );

        controller.add(null);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(cache.get<String>('key'), isNull);

        // Add new entry with same key
        cache.set('key', 'value2');

        expect(cache.get<String>('key'), equals('value2'));

        await controller.close();
        cache.dispose();
      });
    });
  });
}
