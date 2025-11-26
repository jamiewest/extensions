import 'dart:async';
import 'dart:io';

import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

import '../../../primitives/change_token.dart';
import '../../../system/disposable.dart';
import '../../../system/threading/cancellation_token_source.dart';

/// A change token that polls for file changes matching a wildcard pattern.
///
/// This token checks for changes to any files matching the glob pattern
/// at regular intervals and invokes registered callbacks when changes occur.
class PollingWildcardChangeToken implements IChangeToken {
  final String _root;
  final String _pattern;
  final Duration _pollingInterval;
  final CancellationTokenSource? _cancellationTokenSource;
  final List<_CallbackRegistration> _callbacks = [];
  Map<String, DateTime>? _previousState;
  DateTime? _lastCheckedTime;
  bool _hasChanged = false;
  Timer? _pollingTimer;

  /// Creates a new [PollingWildcardChangeToken] for the specified pattern.
  PollingWildcardChangeToken(
    this._root,
    this._pattern, {
    Duration pollingInterval = const Duration(seconds: 4),
    CancellationTokenSource? cancellationTokenSource,
  })  : _pollingInterval = pollingInterval,
        _cancellationTokenSource = cancellationTokenSource {
    _initializeState();
  }

  void _initializeState() {
    _previousState = _getCurrentState();
    _lastCheckedTime = DateTime.now();
  }

  Map<String, DateTime> _getCurrentState() {
    final state = <String, DateTime>{};

    try {
      final glob = Glob(_pattern);
      final rootDir = Directory(_root);

      if (!rootDir.existsSync()) {
        return state;
      }

      // List all files in the root directory recursively
      final entities = rootDir.listSync(recursive: true, followLinks: false);

      for (final entity in entities) {
        if (entity is File) {
          try {
            final relativePath = p.relative(entity.path, from: _root);

            // Check if the file matches the glob pattern
            if (glob.matches(relativePath)) {
              state[relativePath] = entity.lastModifiedSync();
            }
          } catch (e) {
            // Skip files we can't access
          }
        }
      }
    } catch (e) {
      // If we can't list files, return empty state
    }

    return state;
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

    final currentState = _getCurrentState();

    // Check if the state has changed
    if (_previousState == null) {
      _hasChanged = currentState.isNotEmpty;
    } else {
      // Check for added, removed, or modified files
      _hasChanged = _stateHasChanged(_previousState!, currentState);
    }

    if (_hasChanged) {
      _previousState = currentState;
    }

    return _hasChanged;
  }

  bool _stateHasChanged(
    Map<String, DateTime> previous,
    Map<String, DateTime> current,
  ) {
    // Check if number of files changed
    if (previous.length != current.length) {
      return true;
    }

    // Check if any files were added or modified
    for (final entry in current.entries) {
      final previousTime = previous[entry.key];
      if (previousTime == null || previousTime != entry.value) {
        return true;
      }
    }

    // Check if any files were removed
    for (final key in previous.keys) {
      if (!current.containsKey(key)) {
        return true;
      }
    }

    return false;
  }

  void _checkForChanges() {
    if (_hasChanged ||
        (_cancellationTokenSource?.isCancellationRequested ?? false)) {
      return;
    }

    final currentState = _getCurrentState();

    // Check if the state has changed
    final changed = _previousState != null &&
        _stateHasChanged(_previousState!, currentState);

    if (changed) {
      _hasChanged = true;
      _previousState = currentState;
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
  final PollingWildcardChangeToken _token;
  final _CallbackRegistration? _registration;

  _CallbackDisposable(this._token, this._registration);

  @override
  void dispose() {
    _token._unregisterCallback(_registration);
  }
}
