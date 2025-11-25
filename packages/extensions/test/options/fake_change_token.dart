import 'package:extensions/src/primitives/change_token.dart';
import 'package:extensions/src/primitives/void_callback.dart';
import 'package:extensions/src/system/disposable.dart';

class FakeChangeToken implements ChangeToken, Disposable {
  VoidCallback? _callback;
  bool activeChangeCallbacks = false;
  bool hasChanged = false;

  Disposable? registerChangeCallback(ChangeCallback callback, [Object? state]) {
    _callback = () => callback(state);
    return this;
  }

  void invokeChangeCallback() {
    if (_callback != null) {
      _callback!();
    }
  }

  @override
  void dispose() => _callback = null;
}
