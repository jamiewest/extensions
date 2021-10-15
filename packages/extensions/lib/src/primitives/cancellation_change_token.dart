import '../shared/cancellation_token.dart';
import '../shared/disposable.dart';
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
  Disposable? registerChangeCallback(void Function(Object? state) callback,
      [Object? state]) {
    token.register((state) {
      try {
        callback(state);
      } catch (e) {
        _activeChangeCallbacks = false;
      }
    });
  }
}
