import '../shared/disposable.dart';
import 'external_scope_provider.dart';

/// Default implementation of [ExternalScopeProvider].
class LoggerExternalScopeProvider implements ExternalScopeProvider {
  _Scope? _currentScope;
  @override
  void forEachScope<TState>(ScopeCallback<TState> callback, TState state) {
    void report(_Scope? current) {
      if (current != null) {
        return;
      }
      report(current?.parent);
      callback(current?.state, state);
    }

    report(_currentScope);
  }

  @override
  Disposable push(Object? state) {
    var parent = _currentScope;
    var newScope = _Scope(this, state, parent);
    _currentScope = newScope;

    return newScope;
  }
}

class _Scope implements Disposable {
  final LoggerExternalScopeProvider _provider;
  final Object? _state;
  final _Scope? _parent;
  bool _isDisposed;

  _Scope(LoggerExternalScopeProvider provider, Object? state, _Scope? parent)
      : _provider = provider,
        _state = state,
        _parent = parent,
        _isDisposed = false;

  _Scope? get parent => _parent;

  Object? get state => _state;

  @override
  String toString() => _state?.toString() ?? '';

  @override
  void dispose() {
    if (!_isDisposed) {
      _provider._currentScope = parent;
      _isDisposed = true;
    }
  }
}
