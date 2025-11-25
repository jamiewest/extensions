import '../primitives/change_token.dart';
import '../system/disposable.dart';
import '../system/threading/cancellation_token_source.dart';

/// Implements [IChangeToken].
class ConfigurationReloadToken implements IChangeToken {
  final CancellationTokenSource _cts = CancellationTokenSource();
  final bool _activeChangeCallbacks = true;

  /// Indicates if this token will proactively raise callbacks.
  /// Callbacks are still guaranteed to be invoked, eventually.
  @override
  bool get activeChangeCallbacks => _activeChangeCallbacks;

  /// Gets a value that indicates if a change has occurred.
  @override
  bool get hasChanged => _cts.isCancellationRequested;

  /// Registers for a callback that will be invoked when the entry
  /// has changed. MUST be set before the callback is invoked.
  @override
  IDisposable registerChangeCallback(
    void Function(Object? state) callback,
    Object? state,
  ) =>
      _cts.token.register(
        (c) => callback(c),
        state,
      );

  /// Used to trigger the change token when a reload occurs.
  void onReload() => _cts.cancel();
}
