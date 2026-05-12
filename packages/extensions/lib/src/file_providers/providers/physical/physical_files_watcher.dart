import 'dart:async';
import 'dart:io';

import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:stream_transform/stream_transform.dart';
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
/// Supports both event-based watching (using [Watcher]) and polling-based
/// watching for compatibility with different file systems.
class PhysicalFilesWatcher implements Disposable {
  final String _root;
  final bool _usePolling;
  final Duration _pollingInterval;
  final CancellationTokenSource _cancellationTokenSource =
      CancellationTokenSource();
  Watcher? _watcher;
  final StreamController<WatchEvent> _eventsController =
      StreamController<WatchEvent>.broadcast();
  StreamSubscription<WatchEvent>? _watcherSubscription;

  /// Creates a new [PhysicalFilesWatcher] for the specified root directory.
  ///
  /// [root] - The root directory to watch.
  /// [useEventBasedWatcher] - If true, subscribes to filesystem events and
  /// debounces bursts; otherwise polls on each token's interval.
  /// [pollingInterval] - The interval at which polling tokens check for
  /// changes.
  PhysicalFilesWatcher(
    String root,
    bool useEventBasedWatcher, {
    Duration pollingInterval = const Duration(seconds: 4),
  })  : _root = root,
        _usePolling = !useEventBasedWatcher,
        _pollingInterval = pollingInterval {
    if (useEventBasedWatcher) {
      _initializeEventWatcher();
    }
  }

  void _initializeEventWatcher() {
    try {
      _watcher = Watcher(_root);
      _watcherSubscription = _watcher!.events
          .debounce(const Duration(milliseconds: 200))
          .listen(_eventsController.add);
    } catch (_) {
      _watcher = null;
    }
  }

  /// Creates a change token for the specified filter pattern.
  ///
  /// [filter] can be:
  /// - A specific file path (e.g., "appsettings.json")
  /// - A glob pattern (e.g., "**/*.json", "config/*.xml")
  /// - A directory path (e.g., "logs/")
  ChangeToken createFileChangeToken(String filter) {
    if (filter.isEmpty) {
      return NullChangeToken();
    }

    final normalizedFilter = p.normalize(filter);

    if (_isWildcardPattern(normalizedFilter)) {
      return _createWildcardToken(normalizedFilter);
    }

    final fullPath = p.isAbsolute(normalizedFilter)
        ? normalizedFilter
        : p.join(_root, normalizedFilter);

    final entity = FileSystemEntity.typeSync(fullPath);

    if (entity == FileSystemEntityType.directory) {
      return _createWildcardToken(p.join(normalizedFilter, '*'));
    }

    return _createFileToken(fullPath);
  }

  bool _isWildcardPattern(String pattern) =>
      pattern.contains('*') ||
      pattern.contains('?') ||
      pattern.contains('[') ||
      pattern.contains('{');

  ChangeToken _createFileToken(String filePath) {
    if (!_usePolling && _watcher != null) {
      return _WatcherChangeToken(
        _eventsController.stream.where((e) => e.path == filePath),
        _cancellationTokenSource,
      );
    }
    return PollingFileChangeToken(
      File(filePath),
      pollingInterval: _pollingInterval,
      cancellationTokenSource: _cancellationTokenSource,
    );
  }

  ChangeToken _createWildcardToken(String pattern) {
    if (!_usePolling && _watcher != null) {
      final glob = Glob(pattern);
      return _WatcherChangeToken(
        _eventsController.stream.where((e) {
          final relative = p.relative(e.path, from: _root);
          return glob.matches(relative);
        }),
        _cancellationTokenSource,
      );
    }
    return PollingWildcardChangeToken(
      _root,
      pattern,
      pollingInterval: _pollingInterval,
      cancellationTokenSource: _cancellationTokenSource,
    );
  }

  /// Creates a composite change token that combines multiple patterns.
  ChangeToken createCompositeToken(List<String> filters) {
    final tokens = filters.map(createFileChangeToken).toList();
    return CompositeChangeToken(tokens);
  }

  @override
  void dispose() {
    _watcherSubscription?.cancel();
    _eventsController.close();
    _cancellationTokenSource.cancel();
    _watcher = null;
  }
}

/// A change token backed by an event stream rather than a polling timer.
class _WatcherChangeToken implements ChangeToken {
  final Stream<WatchEvent> _events;
  final CancellationTokenSource _cts;
  bool _hasChanged = false;
  final List<_Registration> _callbacks = [];
  StreamSubscription<WatchEvent>? _subscription;

  _WatcherChangeToken(this._events, this._cts);

  @override
  bool get hasChanged {
    if (_hasChanged) return true;
    if (_cts.isCancellationRequested) {
      _hasChanged = true;
      return true;
    }
    return false;
  }

  @override
  bool get activeChangeCallbacks => _callbacks.isNotEmpty;

  @override
  Disposable registerChangeCallback(
    void Function(Object? state) callback,
    Object? state,
  ) {
    if (_hasChanged) {
      try {
        callback(state);
      } catch (_) {}
      return _NoOpDisposable();
    }

    final reg = _Registration(callback, state);
    _callbacks.add(reg);
    _subscription ??= _events.listen((_) => _onChanged());
    return _RegistrationDisposable(this, reg);
  }

  void _onChanged() {
    _hasChanged = true;
    _subscription?.cancel();
    _subscription = null;
    for (final reg in List<_Registration>.of(_callbacks)) {
      try {
        reg.callback(reg.state);
      } catch (_) {}
    }
  }

  void _unregister(_Registration reg) {
    _callbacks.remove(reg);
    if (_callbacks.isEmpty) {
      _subscription?.cancel();
      _subscription = null;
    }
  }
}

class _Registration {
  final void Function(Object? state) callback;
  final Object? state;

  _Registration(this.callback, this.state);
}

class _RegistrationDisposable implements Disposable {
  final _WatcherChangeToken _token;
  final _Registration _registration;

  _RegistrationDisposable(this._token, this._registration);

  @override
  void dispose() => _token._unregister(_registration);
}

class _NoOpDisposable implements Disposable {
  @override
  void dispose() {}
}
