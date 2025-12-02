import 'package:extensions/primitives.dart';
import 'package:extensions/system.dart';

/// A mock implementation of PhysicalFilesWatcher for testing.
///
/// This mock allows tests to manually trigger file change events
/// without relying on actual file system operations, making tests
/// deterministic and fast.
class MockPhysicalFilesWatcher {
  final String _root;
  final Map<String, List<MockChangeToken>> _tokens = {};

  MockPhysicalFilesWatcher(this._root);

  String get root => _root;

  /// Creates a change token that can be manually triggered in tests.
  MockChangeToken createFileChangeToken(String filter) {
    final token = MockChangeToken(filter);
    _tokens.putIfAbsent(filter, () => []).add(token);
    return token;
  }

  /// Manually trigger a file change event for a specific filter pattern.
  void triggerChange(String filter) {
    final tokens = _tokens[filter];
    if (tokens != null) {
      for (final token in tokens) {
        token.trigger();
      }
    }
  }

  /// Trigger change for all tokens matching a file path.
  void triggerChangeForFile(String filePath) {
    for (final entry in _tokens.entries) {
      final filter = entry.key;
      final tokens = entry.value;

      // Simple pattern matching - in production you'd use glob matching
      if (_matchesFilter(filePath, filter)) {
        for (final token in tokens) {
          token.trigger();
        }
      }
    }
  }

  bool _matchesFilter(String path, String filter) {
    // Simple wildcard matching for testing
    if (filter == '**/*' || filter == '*') {
      return true;
    }

    if (filter.startsWith('*.')) {
      final ext = filter.substring(1);
      return path.endsWith(ext);
    }

    return path == filter;
  }

  void dispose() {
    _tokens.clear();
  }
}

/// A mock change token that can be manually triggered.
class MockChangeToken implements IChangeToken {
  final String filter;
  final List<_CallbackRegistration> _callbacks = [];
  bool _hasChanged = false;

  MockChangeToken(this.filter);

  @override
  bool get hasChanged => _hasChanged;

  @override
  bool get activeChangeCallbacks => _callbacks.isNotEmpty;

  @override
  IDisposable registerChangeCallback(
    void Function(Object? state) callback,
    Object? state,
  ) {
    if (_hasChanged) {
      // Immediately invoke if already changed
      try {
        callback(state);
      } catch (e) {
        // Ignore exceptions in callbacks
      }
      return _CallbackDisposable(this, null);
    }

    final registration = _CallbackRegistration(callback, state);
    _callbacks.add(registration);
    return _CallbackDisposable(this, registration);
  }

  /// Manually trigger this token's change callbacks.
  void trigger() {
    if (_hasChanged) {
      return;
    }

    _hasChanged = true;
    final callbacks = List<_CallbackRegistration>.from(_callbacks);

    for (final registration in callbacks) {
      try {
        registration.callback(registration.state);
      } catch (e) {
        // Ignore exceptions in callbacks
      }
    }
  }

  void _unregisterCallback(_CallbackRegistration? registration) {
    if (registration != null) {
      _callbacks.remove(registration);
    }
  }
}

class _CallbackRegistration {
  final void Function(Object? state) callback;
  final Object? state;

  _CallbackRegistration(this.callback, this.state);
}

class _CallbackDisposable implements IDisposable {
  final MockChangeToken _token;
  final _CallbackRegistration? _registration;

  _CallbackDisposable(this._token, this._registration);

  @override
  void dispose() {
    _token._unregisterCallback(_registration);
  }
}
