import '../../../../file_providers.dart' show PhysicalFileProvider;
import 'exclusion_filters.dart';
import 'physical_file_provider.dart' show PhysicalFileProvider;

/// Options for a [PhysicalFileProvider].
class PhysicalFileProviderOptions {
  /// Creates options for a physical file provider.
  PhysicalFileProviderOptions({
    this.exclusionFilters = ExclusionFilters.sensitive,
    this.usePollingFileWatcher = false,
    this.useActivePolling = false,
    this.pollingInterval = const Duration(seconds: 4),
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

  /// Determines whether change token callbacks will be raised via active
  /// polling.
  ///
  /// When true, change callbacks will poll the file system for changes rather
  /// than passively waiting for file system events.
  ///
  /// Defaults to false.
  final bool useActivePolling;

  /// The interval at which to poll for file changes when using polling-based
  /// change detection.
  ///
  /// This applies when callbacks are registered on change tokens.
  ///
  /// Defaults to 4 seconds.
  final Duration pollingInterval;

  /// Creates a copy of these options with the specified values overridden.
  PhysicalFileProviderOptions copyWith({
    ExclusionFilters? exclusionFilters,
    bool? usePollingFileWatcher,
    bool? useActivePolling,
    Duration? pollingInterval,
  }) =>
      PhysicalFileProviderOptions(
        exclusionFilters: exclusionFilters ?? this.exclusionFilters,
        usePollingFileWatcher:
            usePollingFileWatcher ?? this.usePollingFileWatcher,
        useActivePolling: useActivePolling ?? this.useActivePolling,
        pollingInterval: pollingInterval ?? this.pollingInterval,
      );
}
