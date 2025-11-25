import '../system/disposable.dart';

/// Propagates notifications that a change has occurred.
///
/// Adapted from [`Microsoft.Extensions.Primitives`]()
abstract class IChangeToken {
  /// Gets a value that indicates if a change has occurred.
  bool get hasChanged;

  /// Indicates if this token will pro-actively raise callbacks.
  /// If `false`, the token consumer must poll [hasChanged] to detect changes.
  bool get activeChangeCallbacks;

  /// Registers for a callback that will be invoked when the entry has changed.
  /// [hasChanged] MUST be set before the callback is invoked.
  IDisposable registerChangeCallback(
    void Function(Object? state) callback,
    Object? state,
  );
}

class ChangeToken {
  /// Registers the [changeTokenConsumer] action to be called whenever
  /// the token produced changes.
  static IDisposable onChangeWithState<TState>(
    ChangeTokenProducer changeTokenProducer,
    ChangeTokenTypedConsumer<TState> changeTokenConsumer,
    TState? state,
  ) =>
      _ChangeTokenRegistration<TState>(
        changeTokenProducer,
        changeTokenConsumer,
        state,
      );

  static IDisposable onChange(
    ChangeTokenProducer changeTokenProducer,
    ChangeTokenConsumer changeTokenConsumer,
  ) =>
      _ChangeTokenRegistration<Function>(
        changeTokenProducer,
        (s) => changeTokenConsumer(),
        changeTokenConsumer,
      );
}

class _ChangeTokenRegistration<TState> implements IDisposable {
  final ChangeTokenProducer _changeTokenProducer;
  final ChangeTokenTypedConsumer<TState> _changeTokenConsumer;
  final TState? _state;
  IDisposable? _disposable;

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

  void _registerChangeTokenCallback(IChangeToken? token) {
    if (token == null) {
      return;
    }

    final registration = token.registerChangeCallback(
      (s) => (s as _ChangeTokenRegistration<TState>)._onChangeTokenFired(),
      this,
    );

    if (token.hasChanged && token.activeChangeCallbacks) {
      registration.dispose();
      return;
    }

    setDisposable(registration);
  }

  void setDisposable(IDisposable? disposable) {
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

class NoopDisposable implements IDisposable {
  @override
  void dispose() {}
}

/// Produces the change token.
typedef ChangeTokenProducer = IChangeToken? Function();

/// Action called when the token changes.
typedef ChangeTokenConsumer = void Function();

/// Action called when the token changes with state.
typedef ChangeTokenTypedConsumer<TState> = void Function(TState? state);

/// Callback signature for change notifications.
typedef ChangeCallback = void Function(Object? state);
