import 'memory_cache_entry_options.dart';

/// Holds statistics for the memory cache.
///
/// This class provides a snapshot of cache performance metrics at a point
/// in time.
class MemoryCacheStatistics {
  /// Creates a new instance of [MemoryCacheStatistics].
  const MemoryCacheStatistics({
    required this.currentEntryCount,
    this.currentEstimatedSize,
    required this.totalMisses,
    required this.totalHits,
  });

  /// Gets the number of entries currently in the cache.
  final int currentEntryCount;

  /// Gets the estimated size of the cache in bytes, or `null` if size tracking
  /// is not enabled.
  ///
  /// The size is an estimate based on the [size] values set in
  /// [MemoryCacheEntryOptions]. The units are arbitrary and defined by
  /// the application.
  final int? currentEstimatedSize;

  /// Gets the total number of cache misses.
  ///
  /// A cache miss occurs when a requested key is not found in the cache.
  final int totalMisses;

  /// Gets the total number of cache hits.
  ///
  /// A cache hit occurs when a requested key is found in the cache.
  final int totalHits;

  @override
  String toString() => 'MemoryCacheStatistics('
      'currentEntryCount: $currentEntryCount, '
      'currentEstimatedSize: $currentEstimatedSize, '
      'totalMisses: $totalMisses, '
      'totalHits: $totalHits)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoryCacheStatistics &&
          runtimeType == other.runtimeType &&
          currentEntryCount == other.currentEntryCount &&
          currentEstimatedSize == other.currentEstimatedSize &&
          totalMisses == other.totalMisses &&
          totalHits == other.totalHits;

  @override
  int get hashCode =>
      currentEntryCount.hashCode ^
      currentEstimatedSize.hashCode ^
      totalMisses.hashCode ^
      totalHits.hashCode;
}
