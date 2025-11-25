import 'exclusion_filters.dart';

/// Options for a [PhysicalFileProvider].
class PhysicalFileProviderOptions {
  /// Creates options for a physical file provider.
  PhysicalFileProviderOptions({
    this.exclusionFilters = ExclusionFilters.sensitive,
    this.usePollingFileWatcher = false,
    this.useActivePolling = false,
  });

  /// Determines which files or directories are excluded from enumeration
  /// and change tracking.
  ///
  /// Defaults to [ExclusionFilters.sensitive].
  final ExclusionFilters exclusionFilters;

  /// Determines whether to use polling for file change detection.
  ///
  /// When true, uses polling instead of file system events.
  /// This can be useful in scenarios where file system events are unreliable,
  /// such as network file systems or containers.
  ///
  /// Defaults to false.
  final bool usePollingFileWatcher;

  /// Determines whether change token callbacks will be raised via active polling.
  ///
  /// When true, change callbacks will poll the file system for changes rather
  /// than passively waiting for file system events.
  ///
  /// Defaults to false.
  final bool useActivePolling;

  /// Creates a copy of these options with the specified values overridden.
  PhysicalFileProviderOptions copyWith({
    ExclusionFilters? exclusionFilters,
    bool? usePollingFileWatcher,
    bool? useActivePolling,
  }) {
    return PhysicalFileProviderOptions(
      exclusionFilters: exclusionFilters ?? this.exclusionFilters,
      usePollingFileWatcher:
          usePollingFileWatcher ?? this.usePollingFileWatcher,
      useActivePolling: useActivePolling ?? this.useActivePolling,
    );
  }
}
