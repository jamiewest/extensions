import '../shared/cancellation_token.dart';
import '../shared/disposable.dart';
import 'change_token.dart';

/// An [ChangeToken] which represents one or more [ChangeToken] instances.
class CompositeChangeToken extends ChangeToken {
  void Function(Object? state)? _onChangeDelegate;
  CancellationTokenSource? _cancellationTokenSource;
  bool _registeredCallbackProxy;
  final List<ChangeToken> _changeTokens;
  bool? _activeChangeCallbacks;

  CompositeChangeToken(List<ChangeToken> changeTokens)
      : _changeTokens = changeTokens,
        _registeredCallbackProxy = false {
    for (var i = 0; i < _changeTokens.length; i++) {
      if (_changeTokens[i].activeChangeCallbacks) {
        _activeChangeCallbacks = true;
        return;
      }
    }
    _activeChangeCallbacks = false;
  }

  List<ChangeToken> get changeTokens => _changeTokens;

  @override
  bool get activeChangeCallbacks => _activeChangeCallbacks!;

  @override
  bool get hasChanged {
    if (_cancellationTokenSource != null) {
      if (_cancellationTokenSource!.token.isCancellationRequested) {
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
    return false;
  }

  @override
  Disposable? registerChangeCallback(Function callback, [Object? state]) {
    _ensureCallbacksInitialized();
    return _cancellationTokenSource!.token.register((state) {
      callback(state);
    });
  }

  void _ensureCallbacksInitialized() {
    if (_registeredCallbackProxy) {
      return;
    }

    _cancellationTokenSource = CancellationTokenSource();
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

  static void onChange(Object state) {
    var compositeChangeTokenState = state as CompositeChangeToken;
    if (compositeChangeTokenState._cancellationTokenSource == null) {
      return;
    }
    try {
      compositeChangeTokenState._cancellationTokenSource?.cancel();
      // ignore: empty_catches
    } catch (e) {}
  }
}
