import '../shared/disposable.dart';

/// An empty scope without any logic.
class NullScope implements Disposable {
  static NullScope get instance => NullScope();

  @override
  void dispose() {}
}
