import '../primitives/change_token.dart';
import '../primitives/empty_disposable.dart';
import '../system/disposable.dart';

/// An empty change token that doesn't raise any change callbacks.
class NullChangeToken implements IChangeToken {
  NullChangeToken();

  /// A singleton instance of [NullChangeToken]
  factory NullChangeToken.singleton() => NullChangeToken();

  /// Always false.
  @override
  bool get hasChanged => false;

  /// Always false.
  @override
  bool get activeChangeCallbacks => false;

  /// Always returns an empty disposable object. Callbacks will never be called.
  @override
  IDisposable registerChangeCallback(
    void Function(Object? state) callback,
    Object? state,
  ) =>
      EmptyDisposable.instance();
}
