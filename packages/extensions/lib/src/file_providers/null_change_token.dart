import '../primitives/change_token.dart';
import '../primitives/empty_disposable.dart';
import '../shared/disposable.dart';

/// An empty change token that doesn't raise any change callbacks.
class NullChangeToken implements ChangeToken {
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
  Disposable? registerChangeCallback(ChangeCallback callback,
          [Object? state]) =>
      EmptyDisposable.instance();
}
