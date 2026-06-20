import '../dependency_injection/service_collection.dart';
import '../dependency_injection/service_collection_descriptor_extensions.dart';
import '../dependency_injection/service_descriptor.dart';
import '../dependency_injection/service_provider.dart';
import '../dependency_injection/service_provider_service_extensions.dart';
import '../options/options.dart';
import '../options/options_service_collection_extensions.dart';
import 'distributed_cache.dart';
import 'memory/memory_cache_impl.dart';
import 'memory/memory_distributed_cache.dart';
import 'memory_cache.dart';
import 'memory_cache_options.dart';
import 'memory_distributed_cache_options.dart';

/// Extension methods for registering caching services on a
/// [ServiceCollection].
extension MemoryCacheServiceCollectionExtensions on ServiceCollection {
  /// Adds a non-distributed in-memory [MemoryCache] to the service
  /// collection as a singleton.
  ///
  /// Pass [configureOptions] to configure the [MemoryCacheOptions] used by
  /// the cache.
  ServiceCollection addMemoryCache({
    void Function(MemoryCacheOptions options)? configureOptions,
  }) {
    addOptions<MemoryCacheOptions>(MemoryCacheOptions.new);

    tryAdd(
      ServiceDescriptor.singleton<MemoryCache>(
        (ServiceProvider sp) => MemoryCacheImpl(
          sp.getRequiredService<Options<MemoryCacheOptions>>().value ??
              MemoryCacheOptions(),
        ),
      ),
    );

    if (configureOptions != null) {
      configure<MemoryCacheOptions>(MemoryCacheOptions.new, configureOptions);
    }

    return this;
  }

  /// Adds a default in-memory implementation of [DistributedCache] to the
  /// service collection as a singleton.
  ///
  /// This is intended for development and single-server scenarios. Pass
  /// [configureOptions] to configure the [MemoryDistributedCacheOptions].
  ServiceCollection addDistributedMemoryCache({
    void Function(MemoryDistributedCacheOptions options)? configureOptions,
  }) {
    addOptions<MemoryDistributedCacheOptions>(
        MemoryDistributedCacheOptions.new);

    tryAdd(
      ServiceDescriptor.singleton<DistributedCache>(
        (ServiceProvider sp) => MemoryDistributedCache(
          sp.getRequiredService<Options<MemoryDistributedCacheOptions>>().value,
        ),
      ),
    );

    if (configureOptions != null) {
      configure<MemoryDistributedCacheOptions>(
        MemoryDistributedCacheOptions.new,
        configureOptions,
      );
    }

    return this;
  }
}
