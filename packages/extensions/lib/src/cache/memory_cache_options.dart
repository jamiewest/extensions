import '../options/options.dart';
import 'system_clock.dart';

class MemoryCacheOptions extends Options<MemoryCacheOptions> {
  int? _sizeLimit;
  double _compactionPercentage = 0.05;

  SystemClock? clock;

  /// Gets or sets the minimum length of time between successive scans
  /// for expired items.
  Duration? expirationScanFrequency = const Duration(minutes: 1);

  /// Gets the maximum size of the cache.
  int? get sizeLimit => _sizeLimit;

  /// Sets the maximum size of the cache.
  set sizeLimit(int? value) {
    if (value != null) {
      if (value < 0) {
        throw ArgumentError.value(
          value,
          'sizeLimit',
          'value must be non-negative.',
        );
      }
    }
    _sizeLimit = value;
  }

  /// Gets the amount to compact the cache by when the maximum size is exceeded.
  double get compactionPercentage => _compactionPercentage;

  /// Sets the amount to compact the cache by when the maximum size is exceeded.
  set compactionPercentage(double value) {
    if (value < 0 || value > 1) {
      throw ArgumentError.value(
        value,
        'compactionPercentage',
        'value must be between 0 and 1 inclusive.',
      );
    }

    _compactionPercentage = value;
  }

  /// Gets or sets whether to track linked entries. Disabled by default.
  bool trackLinkedCacheEntries = false;

  @override
  MemoryCacheOptions? get value => this;
}
