import '../common/disposable.dart';

/// Produces the change token.
typedef ChangeTokenProducer = ChangeToken? Function();

/// Action called when the token changes.
typedef ChangeTokenConsumer = void Function();

typedef ChangeTokenTypedConsumer<TState> = void Function(TState? state);

typedef ChangeCallback = void Function(Object? state);

/// Propagates notifications that a change has occurred.
abstract class ChangeToken {
  /// Gets a value that indicates if a change has occurred.
  bool get hasChanged;

  /// Indicates if this token will pro-actively raise callbacks.
  /// If `false`, the token consumer must poll `HasChanged` to detect changes.
  bool get activeChangeCallbacks;

  /// Registers for a callback that will be invoked when the entry has changed.
  Disposable? registerChangeCallback(ChangeCallback callback, [Object? state]);

  /// Registers the `changeTokenConsumer` action to be called whenever
  /// the token produced changes.
  static Disposable onChangeWithState<TState>(
    ChangeTokenProducer changeTokenProducer,
    ChangeTokenTypedConsumer<TState> changeTokenConsumer,
    TState? state,
  ) =>
      _ChangeTokenRegistration<TState>(
        changeTokenProducer,
        changeTokenConsumer,
        state,
      );

  static Disposable onChange(
    ChangeTokenProducer changeTokenProducer,
    ChangeTokenConsumer changeTokenConsumer,
  ) =>
      _ChangeTokenRegistration<Function>(
        changeTokenProducer,
        (s) => changeTokenConsumer(),
        changeTokenConsumer,
      );
}

class _ChangeTokenRegistration<TState> implements Disposable {
  final ChangeTokenProducer _changeTokenProducer;
  final ChangeTokenTypedConsumer<TState> _changeTokenConsumer;
  final TState? _state;
  Disposable? _disposable;

  static final NoopDisposable _disposedSentinel = NoopDisposable();

  _ChangeTokenRegistration(
    this._changeTokenProducer,
    this._changeTokenConsumer,
    this._state,
  ) {
    var token = _changeTokenProducer();

    _registerChangeTokenCallback(token);
  }

  void _onChangeTokenFired() {
    var token = _changeTokenProducer();

    try {
      _changeTokenConsumer(_state);
    } finally {
      // We always want to ensure the callback is registered
      _registerChangeTokenCallback(token);
    }
  }

  void _registerChangeTokenCallback(ChangeToken? token) {
    if (token == null) {
      return;
    }

    final registration = token.registerChangeCallback(
      (s) => (s as _ChangeTokenRegistration<TState>)._onChangeTokenFired(),
      this,
    );

    if (token.hasChanged && token.activeChangeCallbacks) {
      registration?.dispose();
      return;
    }

    setDisposable(registration);
  }

  void setDisposable(Disposable? disposable) {
    var current = _disposable;
    if (current == _disposedSentinel) {
      disposable?.dispose();
      return;
    }

    var previous = _disposable;
    if (_disposable == current) {
      _disposable = disposable;
    }

    if (previous == _disposedSentinel) {
      disposable?.dispose();
    }
  }

  @override
  void dispose() {
    _disposable?.dispose();
    _disposedSentinel.dispose();
  }
}

class NoopDisposable implements Disposable {
  @override
  void dispose() {}
}
