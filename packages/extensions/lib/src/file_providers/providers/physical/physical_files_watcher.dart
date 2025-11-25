import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:watcher/watcher.dart';

import '../../../primitives/change_token.dart';
import '../../../primitives/composite_change_token.dart';
import '../../../system/disposable.dart';
import '../../../system/threading/cancellation_token_source.dart';
import '../../null_change_token.dart';
import 'polling_file_change_token.dart';
import 'polling_wildcard_change_token.dart';

/// A file watcher that watches a physical filesystem for changes.
///
/// Supports both event-based watching (using FileSystemWatcher) and
/// polling-based watching for compatibility with different file systems.
class PhysicalFilesWatcher implements Disposable {
  final String _root;
  final bool _usePolling;
  final CancellationTokenSource _cancellationTokenSource =
      CancellationTokenSource();
  Watcher? _watcher;

  /// Creates a new [PhysicalFilesWatcher] for the specified root directory.
  ///
  /// [root] - The root directory to watch
  /// [useEventBasedWatcher] - If true, uses event-based file watching.
  /// If false, uses polling.
  PhysicalFilesWatcher(
    String root,
    bool useEventBasedWatcher,
  )   : _root = root,
        _usePolling = !useEventBasedWatcher {
    if (useEventBasedWatcher) {
      _initializeEventWatcher();
    }
  }

  void _initializeEventWatcher() {
    try {
      _watcher = Watcher(
        _root,
        pollingDelay: _usePolling ? const Duration(seconds: 4) : null,
      );
    } catch (e) {
      // Failed to create watcher, will fall back to polling
      _watcher = null;
    }
  }

  /// Creates a change token for the specified filter pattern.
  ///
  /// [filter] can be:
  /// - A specific file path (e.g., "appsettings.json")
  /// - A glob pattern (e.g., "**/*.json", "config/*.xml")
  /// - A directory path (e.g., "logs/")
  ///
  /// The change token will report changes to any files matching the pattern.
  IChangeToken createFileChangeToken(String filter) {
    if (filter.isEmpty) {
      return NullChangeToken();
    }

    // Normalize the filter path
    final normalizedFilter = p.normalize(filter);

    // Check if this is a wildcard pattern
    if (_isWildcardPattern(normalizedFilter)) {
      return _createWildcardToken(normalizedFilter);
    }

    // Check if this is a directory
    final fullPath = p.isAbsolute(normalizedFilter)
        ? normalizedFilter
        : p.join(_root, normalizedFilter);

    final entity = FileSystemEntity.typeSync(fullPath);

    if (entity == FileSystemEntityType.directory) {
      // Watch all files in the directory
      return _createWildcardToken(p.join(normalizedFilter, '*'));
    }

    // Watch a specific file
    return _createFileToken(fullPath);
  }

  bool _isWildcardPattern(String pattern) => pattern.contains('*') ||
        pattern.contains('?') ||
        pattern.contains('[') ||
        pattern.contains('{');

  IChangeToken _createFileToken(String filePath) {
    if (_usePolling || _watcher == null) {
      return PollingFileChangeToken(
        File(filePath),
        cancellationTokenSource: _cancellationTokenSource,
      );
    }

    // For event-based watching, we still use polling token
    // but could be enhanced to use the watcher's events
    return PollingFileChangeToken(
      File(filePath),
      cancellationTokenSource: _cancellationTokenSource,
    );
  }

  IChangeToken _createWildcardToken(String pattern) {
    if (_usePolling || _watcher == null) {
      return PollingWildcardChangeToken(
        _root,
        pattern,
        cancellationTokenSource: _cancellationTokenSource,
      );
    }

    // For event-based watching, we could use the watcher's events
    // For now, use polling token
    return PollingWildcardChangeToken(
      _root,
      pattern,
      cancellationTokenSource: _cancellationTokenSource,
    );
  }

  /// Creates a composite change token that combines multiple patterns.
  IChangeToken createCompositeToken(List<String> filters) {
    final tokens = filters.map(createFileChangeToken).toList();
    return CompositeChangeToken(tokens);
  }

  @override
  void dispose() {
    _cancellationTokenSource.cancel();
    _watcher = null;
  }
}
