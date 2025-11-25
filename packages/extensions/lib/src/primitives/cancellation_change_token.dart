import '../system/disposable.dart';
import '../system/threading/cancellation_token.dart';
import 'change_token.dart';

/// A [IChangeToken] implementation using [CancellationToken].
class CancellationChangeToken implements IChangeToken {
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
  IDisposable registerChangeCallback(
    void Function(Object? state) callback,
    Object? state,
  ) =>
      token.register(
        (state) {
          try {
            callback(state);
          } catch (e) {
            _activeChangeCallbacks = false;
          }
        },
      );
}
