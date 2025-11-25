import 'dart:io';

import '../../../primitives/change_token.dart';
import '../../../primitives/empty_disposable.dart';
import '../../../system/disposable.dart';
import '../../../system/threading/cancellation_token_source.dart';

/// A change token that polls for file changes.
///
/// This token checks the file's last modified time at regular intervals
/// to detect changes.
class PollingFileChangeToken implements IChangeToken {
  final File _file;
  final Duration _pollingInterval;
  final CancellationTokenSource? _cancellationTokenSource;
  DateTime? _previousWriteTime;
  DateTime? _lastCheckedTime;
  bool _hasChanged = false;

  /// Creates a new [PollingFileChangeToken] for the specified file.
  PollingFileChangeToken(
    this._file, {
    Duration pollingInterval = const Duration(seconds: 4),
    CancellationTokenSource? cancellationTokenSource,
  })  : _pollingInterval = pollingInterval,
        _cancellationTokenSource = cancellationTokenSource {
    _initializeWriteTime();
  }

  void _initializeWriteTime() {
    try {
      if (_file.existsSync()) {
        _previousWriteTime = _file.lastModifiedSync();
      }
    } catch (e) {
      // File may not exist or be accessible
      _previousWriteTime = null;
    }
    _lastCheckedTime = DateTime.now();
  }

  @override
  bool get hasChanged {
    if (_hasChanged) {
      return true;
    }

    // Check if cancellation was requested
    if (_cancellationTokenSource?.isCancellationRequested ?? false) {
      _hasChanged = true;
      return true;
    }

    // Only check if enough time has passed since last check
    final now = DateTime.now();
    if (_lastCheckedTime != null &&
        now.difference(_lastCheckedTime!) < _pollingInterval) {
      return false;
    }

    _lastCheckedTime = now;

    try {
      if (_file.existsSync()) {
        final currentWriteTime = _file.lastModifiedSync();

        if (_previousWriteTime == null) {
          // File was created
          _hasChanged = true;
        } else if (currentWriteTime != _previousWriteTime) {
          // File was modified
          _hasChanged = true;
        }
      } else if (_previousWriteTime != null) {
        // File was deleted
        _hasChanged = true;
      }
    } catch (e) {
      // If we can't access the file, consider it changed
      _hasChanged = true;
    }

    return _hasChanged;
  }

  @override
  bool get activeChangeCallbacks => false;

  @override
  IDisposable registerChangeCallback(
    void Function(Object? state) callback,
    Object? state,
  ) =>
      // This implementation doesn't support active callbacks
      // Consumers must poll hasChanged
      EmptyDisposable.instance();
}
