import '../../caching.dart' show MemoryCache, MemoryCacheEntryOptions;

/// Provides configuration options for [MemoryCache].
class MemoryCacheOptions {
  /// Creates a new instance of [MemoryCacheOptions].
  MemoryCacheOptions({
    this.expirationScanFrequency = const Duration(minutes: 1),
    this.sizeLimit,
    this.compactionPercentage = 0.05,
    this.trackLinkedCacheEntries = false,
    this.trackStatistics = false,
  });

  /// Gets or sets the minimum length of time between successive scans
  /// for expired items.
  ///
  /// Defaults to 1 minute.
  final Duration expirationScanFrequency;

  /// Gets or sets the maximum size of the cache.
  ///
  /// When set, the cache will enforce this limit by removing entries
  /// when the total size exceeds [sizeLimit]. The size is an arbitrary
  /// value defined by the application through [MemoryCacheEntryOptions.size].
  ///
  /// When null (default), the cache has no size limit.
  final int? sizeLimit;

  /// Gets or sets the amount to compact the cache by when the maximum
  /// size is exceeded.
  ///
  /// The value should be between 0.0 and 1.0, representing a percentage.
  /// For example, 0.05 means 5% of entries will be removed.
  ///
  /// Defaults to 0.05 (5%).
  final double compactionPercentage;

  /// Gets or sets a value that determines whether cache entries should
  /// track hierarchical relationships.
  ///
  /// When enabled, cache entries created within the scope of another
  /// cache entry will be linked, and expiration of a parent entry will
  /// cause child entries to expire as well.
  ///
  /// Defaults to false.
  final bool trackLinkedCacheEntries;

  /// Gets or sets a value that determines whether statistics should be
  /// collected for the cache.
  ///
  /// When enabled, statistics such as hit count, miss count, and total
  /// entries are tracked and can be retrieved via
  /// [MemoryCache.getCurrentStatistics].
  ///
  /// Defaults to false.
  final bool trackStatistics;
}
