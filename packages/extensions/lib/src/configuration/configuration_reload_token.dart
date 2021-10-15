import '../primitives/change_token.dart';
import '../shared/cancellation_token.dart';
import '../shared/disposable.dart';

/// Implements [ChangeToken].
class ConfigurationReloadToken implements ChangeToken {
  final CancellationTokenSource _cts = CancellationTokenSource();

  /// Indicates if this token will proactively raise callbacks.
  /// Callbacks are still guaranteed to be invoked, eventually.
  @override
  bool get activeChangeCallbacks => true;

  /// Gets a value that indicates if a change has occurred.
  @override
  bool get hasChanged => _cts.isCancellationRequested;

  /// Registers for a callback that will be invoked when the entry
  /// has changed. MUST be set before the callback is invoked.
  @override
  Disposable? registerChangeCallback(ChangeCallback callback,
          [Object? state]) =>
      _cts.token.register(
        (c) => callback(c),
        state,
      );

  /// Used to trigger the change token when a reload occurs.
  void onReload() => _cts.cancel();
}
