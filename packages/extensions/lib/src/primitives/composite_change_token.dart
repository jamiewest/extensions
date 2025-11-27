import '../system/disposable.dart';
import '../system/exceptions/argument_null_exception.dart';
import '../system/threading/cancellation_token_source.dart';
import 'change_token.dart';

/// An [ChangeToken] which represents one or more [ChangeToken] instances.
class CompositeChangeToken extends IChangeToken {
  void Function(Object? state)? _onChangeDelegate;
  CancellationTokenSource? _cancellationTokenSource;
  bool _registeredCallbackProxy;
  final List<IChangeToken> _changeTokens;
  bool? _activeChangeCallbacks;

  CompositeChangeToken(List<IChangeToken>? changeTokens)
      : _changeTokens = _validateTokens(changeTokens),
        _registeredCallbackProxy = false {

    for (var i = 0; i < _changeTokens.length; i++) {
      if (_changeTokens[i].activeChangeCallbacks) {
        _activeChangeCallbacks = true;
        return;
      }
    }
    _activeChangeCallbacks = false;
  }

  List<IChangeToken> get changeTokens => _changeTokens;

  @override
  bool get activeChangeCallbacks => _activeChangeCallbacks!;

  @override
  bool get hasChanged {
    if (_cancellationTokenSource != null &&
        _cancellationTokenSource!.token.isCancellationRequested) {
      return true;
    }

    for (var i = 0; i < _changeTokens.length; i++) {
      if (_changeTokens[i].hasChanged) {
        onChange(this);
        return true;
      }
    }
    return false;
  }

  @override
  IDisposable registerChangeCallback(
    void Function(Object? state) callback,
    Object? state,
  ) {
    _ensureCallbacksInitialized();
    return _cancellationTokenSource!.token.register((_) {
      callback(state);
    });
  }

  void _ensureCallbacksInitialized() {
    if (_registeredCallbackProxy) {
      return;
    }

    _cancellationTokenSource = CancellationTokenSource();
    _onChangeDelegate = onChange;
    for (var i = 0; i < _changeTokens.length; i++) {
      if (_changeTokens[i].activeChangeCallbacks) {
        _changeTokens[i].registerChangeCallback(
          (state) {
            _onChangeDelegate!(state);
          },
          this,
        );
      }
    }
    _registeredCallbackProxy = true;
  }

  static void onChange(Object? state) {
    if (state == null) return;
    var compositeChangeTokenState = state as CompositeChangeToken;
    if (compositeChangeTokenState._cancellationTokenSource == null) {
      return;
    }
    try {
      compositeChangeTokenState._cancellationTokenSource?.cancel();
      // ignore: empty_catches
    } catch (e) {}
  }

  static List<IChangeToken> _validateTokens(List<IChangeToken>? tokens) {
    ArgumentNullException.throwIfNull(tokens, 'changeTokens');
    return tokens!;
  }
}
