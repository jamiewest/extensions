import 'dart:typed_data';

import 'package:extensions/caching.dart';
import 'package:extensions/dependency_injection.dart';
import 'package:extensions/options.dart';
import 'package:extensions/system.dart' show Disposable;
import 'package:test/test.dart';

void main() {
  group('addMemoryCache', () {
    test('registers MemoryCache resolvable as a singleton', () {
      // Arrange
      final services = ServiceCollection()..addMemoryCache();
      final container = services.buildServiceProvider();

      // Act
      final first = container.getRequiredService<MemoryCache>();
      final second = container.getRequiredService<MemoryCache>();

      // Assert
      expect(first, isA<MemoryCache>());
      expect(second, same(first));
    });

    test('does not register the cache more than once', () {
      // Arrange
      final services = ServiceCollection()
        ..addMemoryCache()
        ..addMemoryCache();
      final container = services.buildServiceProvider();

      // Act
      final caches = container.getServices<MemoryCache>().toList();

      // Assert
      expect(caches, hasLength(1));
    });

    test('applies configureOptions to the resolved cache', () {
      // Arrange
      final services = ServiceCollection()
        ..addMemoryCache(
          configureOptions: (options) => options.trackStatistics = true,
        );
      final container = services.buildServiceProvider();

      // Act
      final cache = container.getRequiredService<MemoryCache>();

      // Assert
      expect(cache.getCurrentStatistics(), isNotNull);
    });

    test('disposing the provider disposes the cache singleton', () {
      // Arrange
      final services = ServiceCollection()..addMemoryCache();
      final provider = services.buildServiceProvider();
      final cache = provider.getRequiredService<MemoryCache>()
        ..set('key', 'value');
      expect(cache.get<String>('key'), 'value');

      // Act
      (provider as Disposable).dispose();

      // Assert
      expect(cache.get<String>('key'), isNull);
    });
  });

  group('addDistributedMemoryCache', () {
    test('registers DistributedCache resolvable as a singleton', () {
      // Arrange
      final services = ServiceCollection()..addDistributedMemoryCache();
      final container = services.buildServiceProvider();

      // Act
      final first = container.getRequiredService<DistributedCache>();
      final second = container.getRequiredService<DistributedCache>();

      // Assert
      expect(first, isA<DistributedCache>());
      expect(second, same(first));
    });

    test('round-trips values through the resolved cache', () async {
      // Arrange
      final services = ServiceCollection()..addDistributedMemoryCache();
      final container = services.buildServiceProvider();
      final cache = container.getRequiredService<DistributedCache>();
      final payload = Uint8List.fromList(<int>[1, 2, 3]);

      // Act
      await cache.set('key', payload);
      final result = await cache.get('key');

      // Assert
      expect(result, equals(payload));
    });

    test('applies configureOptions to the bound options', () {
      // Arrange
      final services = ServiceCollection()
        ..addDistributedMemoryCache(
          configureOptions: (options) => options.sizeLimit = 100,
        );
      final container = services.buildServiceProvider();

      // Act
      final options = container
          .getRequiredService<Options<MemoryDistributedCacheOptions>>();

      // Assert
      expect(options.value?.sizeLimit, equals(100));
    });

    test('disposing the provider disposes the cache singleton', () async {
      // Arrange
      final services = ServiceCollection()..addDistributedMemoryCache();
      final provider = services.buildServiceProvider();
      final cache = provider.getRequiredService<DistributedCache>();
      await cache.set('key', Uint8List.fromList(<int>[1, 2, 3]));
      expect(await cache.get('key'), isNotNull);

      // Act
      (provider as Disposable).dispose();

      // Assert
      expect(await cache.get('key'), isNull);
    });
  });
}
