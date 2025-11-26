import 'dart:async';
import 'dart:io';

import '../../../primitives/change_token.dart';
import '../../../system/disposable.dart';
import '../../../system/threading/cancellation_token_source.dart';

/// A change token that polls for file changes.
///
/// This token checks the file's last modified time at regular intervals
/// to detect changes and invokes registered callbacks when changes occur.
class PollingFileChangeToken implements IChangeToken {
  final File _file;
  final Duration _pollingInterval;
  final CancellationTokenSource? _cancellationTokenSource;
  final List<_CallbackRegistration> _callbacks = [];
  DateTime? _previousWriteTime;
  DateTime? _lastCheckedTime;
  bool _hasChanged = false;
  Timer? _pollingTimer;

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
          _previousWriteTime = currentWriteTime;
        } else if (currentWriteTime != _previousWriteTime) {
          // File was modified
          _hasChanged = true;
          _previousWriteTime = currentWriteTime;
        }
      } else if (_previousWriteTime != null) {
        // File was deleted
        _hasChanged = true;
        _previousWriteTime = null;
      }
    } catch (e) {
      // If we can't access the file, consider it changed
      _hasChanged = true;
    }

    return _hasChanged;
  }

  void _checkForChanges() {
    if (_hasChanged ||
        (_cancellationTokenSource?.isCancellationRequested ?? false)) {
      return;
    }

    try {
      if (_file.existsSync()) {
        final currentWriteTime = _file.lastModifiedSync();

        if (_previousWriteTime == null) {
          // File was created
          _hasChanged = true;
          _previousWriteTime = currentWriteTime;
        } else if (currentWriteTime != _previousWriteTime) {
          // File was modified
          _hasChanged = true;
          _previousWriteTime = currentWriteTime;
        }
      } else if (_previousWriteTime != null) {
        // File was deleted
        _hasChanged = true;
        _previousWriteTime = null;
      }
    } catch (e) {
      // If we can't access the file, consider it changed
      _hasChanged = true;
    }

    if (_hasChanged) {
      _invokeCallbacks();
      _stopPolling();
    }
  }

  void _invokeCallbacks() {
    final callbacks = List<_CallbackRegistration>.from(_callbacks);
    for (final registration in callbacks) {
      try {
        registration.callback(registration.state);
      } catch (e) {
        // Ignore callback exceptions
      }
    }
  }

  void _startPolling() {
    if (_pollingTimer != null) {
      return;
    }

    _pollingTimer = Timer.periodic(_pollingInterval, (_) => _checkForChanges());
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  bool get activeChangeCallbacks => _callbacks.isNotEmpty;

  @override
  IDisposable registerChangeCallback(
    void Function(Object? state) callback,
    Object? state,
  ) {
    if (_hasChanged) {
      // If already changed, invoke callback immediately
      try {
        callback(state);
      } catch (e) {
        // Ignore callback exceptions
      }
      return _CallbackDisposable(this, null);
    }

    final registration = _CallbackRegistration(callback, state);
    _callbacks.add(registration);

    // Start polling when first callback is registered
    if (_callbacks.length == 1) {
      _startPolling();
    }

    return _CallbackDisposable(this, registration);
  }

  void _unregisterCallback(_CallbackRegistration? registration) {
    if (registration == null) {
      return;
    }

    _callbacks.remove(registration);

    // Stop polling when last callback is unregistered
    if (_callbacks.isEmpty) {
      _stopPolling();
    }
  }

  void dispose() {
    _stopPolling();
    _callbacks.clear();
  }
}

class _CallbackRegistration {
  final void Function(Object? state) callback;
  final Object? state;

  _CallbackRegistration(this.callback, this.state);
}

class _CallbackDisposable implements IDisposable {
  final PollingFileChangeToken _token;
  final _CallbackRegistration? _registration;

  _CallbackDisposable(this._token, this._registration);

  @override
  void dispose() {
    _token._unregisterCallback(_registration);
  }
}
