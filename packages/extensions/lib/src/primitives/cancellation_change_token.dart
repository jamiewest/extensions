import '../system/disposable.dart';
import '../system/exceptions/object_disposed_exception.dart';
import '../system/threading/cancellation_token.dart';
import 'change_token.dart';

/// A [ChangeToken] implementation using [CancellationToken].
class CancellationChangeToken implements ChangeToken {
  final CancellationToken _cancellationToken;
  bool _activeChangeCallbacks;

  CancellationChangeToken(CancellationToken cancellationToken)
      : _cancellationToken = cancellationToken,
        _activeChangeCallbacks = true;

  CancellationToken get token => _cancellationToken;

  @override
  bool get activeChangeCallbacks => _activeChangeCallbacks;

  @override
  bool get hasChanged => token.isCancellationRequested;

  @override
  Disposable registerChangeCallback(
    void Function(Object? state) callback,
    Object? state,
  ) {
    if (!token.canBeCanceled) {
      return NoopDisposable();
    }

    try {
      return token.register(callback, state);
    } on ObjectDisposedException {
      // Registration failed because the underlying source is disposed; signal
      // that proactive callbacks won't fire so consumers can poll [hasChanged].
      _activeChangeCallbacks = false;
    }

    return NoopDisposable();
  }
}
