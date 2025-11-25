import '../system/disposable.dart';

class EmptyDisposable implements IDisposable {
  EmptyDisposable();

  factory EmptyDisposable.instance() => EmptyDisposable();

  @override
  void dispose() {}
}
