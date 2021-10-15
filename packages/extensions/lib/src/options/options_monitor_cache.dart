typedef CreateOptions<TOptions> = TOptions Function();

/// Used by `OptionsMonitor` to cache [TOptions] instances.
abstract class OptionsMonitorCache<TOptions> {
  /// Gets a named options instance, or adds a new instance created with
  /// [createOptions].
  TOptions getOrAdd(String? name, CreateOptions<TOptions> createOptions);

  /// Tries to adds a new option to the cache, will return false if the name
  /// already exists.
  bool tryAdd(String? name, TOptions options);

  /// Try to remove an options instance.
  bool tryRemove(String? name);

  /// Clears all options instances from the cache.
  void clear();
}
