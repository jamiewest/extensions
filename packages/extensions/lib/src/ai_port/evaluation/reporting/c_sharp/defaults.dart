import 'evaluation_response_cache_provider.dart';

/// A static class that contains default values for various reporting
/// artifacts.
class Defaults {
  Defaults();

  /// Gets a [TimeSpan] that specifies the default amount of time that cached AI
  /// responses should survive in the [EvaluationResponseCacheProvider]'s cache
  /// before they are considered expired and evicted.
  static final Duration defaultTimeToLiveForCacheEntries = TimeSpan.FromDays(
    14,
  );
}
