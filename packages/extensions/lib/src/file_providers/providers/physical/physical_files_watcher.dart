import 'dart:async';

import 'package:file/file.dart';
import 'package:glob/glob.dart';

import '../../../primitives/change_token.dart';
import '../../../primitives/composite_change_token.dart';
import '../../../system/disposable.dart';
import '../../../system/threading/cancellation_token_source.dart';
import '../../null_change_token.dart';
import 'event_watcher.dart';
import 'event_watcher_factory.dart';
import 'polling_file_change_token.dart';
import 'polling_wildcard_change_token.dart';

/// A file watcher that watches a physical filesystem for changes.
///
/// Supports both event-based watching (using an [EventWatcher], available only
/// on VM/native targets) and polling-based watching for filesystems without
/// event support (such as an in-memory filesystem on web).
class PhysicalFilesWatcher implements Disposable {
  final FileSystem _fileSystem;
  final String _root;
  final bool _usePolling;
  final Duration _pollingInterval;
  final CancellationTokenSource _cancellationTokenSource =
      CancellationTokenSource();
  EventWatcher? _eventWatcher;

  /// Creates a new [PhysicalFilesWatcher] for the specified root directory.
  ///
  /// [fileSystem] - The filesystem backing the watched root.
  /// [root] - The root directory to watch.
  /// [useEventBasedWatcher] - If true, subscribes to filesystem events (when
  /// the platform supports them); otherwise polls on each token's interval.
  /// [pollingInterval] - The interval at which polling tokens check for
  /// changes.
  PhysicalFilesWatcher(
    this._fileSystem,
    String root,
    bool useEventBasedWatcher, {
    Duration pollingInterval = const Duration(seconds: 4),
  })  : _root = root,
        _usePolling = !useEventBasedWatcher,
        _pollingInterval = pollingInterval {
    if (useEventBasedWatcher) {
      _eventWatcher = createEventWatcher(root);
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

    final context = _fileSystem.path;
    final normalizedFilter = context.normalize(filter);

    if (_isWildcardPattern(normalizedFilter)) {
      return _createWildcardToken(normalizedFilter);
    }

    final fullPath = context.isAbsolute(normalizedFilter)
        ? normalizedFilter
        : context.join(_root, normalizedFilter);

    if (_fileSystem.isDirectorySync(fullPath)) {
      return _createWildcardToken(context.join(normalizedFilter, '*'));
    }

    return _createFileToken(fullPath);
  }

  bool _isWildcardPattern(String pattern) =>
      pattern.contains('*') ||
      pattern.contains('?') ||
      pattern.contains('[') ||
      pattern.contains('{');

  ChangeToken _createFileToken(String filePath) {
    final watcher = _eventWatcher;
    if (!_usePolling && watcher != null) {
      return _EventChangeToken(
        watcher.events.where((path) => path == filePath),
        _cancellationTokenSource,
      );
    }
    return PollingFileChangeToken(
      _fileSystem.file(filePath),
      pollingInterval: _pollingInterval,
      cancellationTokenSource: _cancellationTokenSource,
    );
  }

  ChangeToken _createWildcardToken(String pattern) {
    final watcher = _eventWatcher;
    if (!_usePolling && watcher != null) {
      final glob = Glob(pattern);
      final context = _fileSystem.path;
      return _EventChangeToken(
        watcher.events.where((path) {
          final relative = context.relative(path, from: _root);
          return glob.matches(relative);
        }),
        _cancellationTokenSource,
      );
    }
    return PollingWildcardChangeToken(
      _fileSystem.directory(_root),
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
    _eventWatcher?.dispose();
    _eventWatcher = null;
    _cancellationTokenSource.cancel();
  }
}

/// A change token backed by an event stream rather than a polling timer.
class _EventChangeToken implements ChangeToken {
  final Stream<Object?> _events;
  final CancellationTokenSource _cts;
  bool _hasChanged = false;
  final List<_Registration> _callbacks = [];
  StreamSubscription<Object?>? _subscription;

  _EventChangeToken(this._events, this._cts);

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
  final _EventChangeToken _token;
  final _Registration _registration;

  _RegistrationDisposable(this._token, this._registration);

  @override
  void dispose() => _token._unregister(_registration);
}

class _NoOpDisposable implements Disposable {
  @override
  void dispose() {}
}
