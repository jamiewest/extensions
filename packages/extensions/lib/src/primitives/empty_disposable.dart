import '../shared/disposable.dart';

class EmptyDisposable implements Disposable {
  EmptyDisposable();

  factory EmptyDisposable.instance() => EmptyDisposable();

  @override
  void dispose() {}
}
