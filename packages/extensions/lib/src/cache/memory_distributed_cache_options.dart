import 'memory_cache_options.dart';

class MemoryDistributedCacheOptions extends MemoryCacheOptions {
  MemoryDistributedCacheOptions() {
    // Default size limit of 200 MB
    sizeLimit = 200 * 1024 * 1024;
  }
}
