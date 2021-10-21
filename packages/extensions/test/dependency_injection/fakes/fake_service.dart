import 'package:extensions/src/shared/disposable.dart';

class FakeService implements Disposable {
  FakeService() : disposed = false;
  PocoClass? value;

  bool? disposed;

  @override
  void dispose() {
    if (disposed!) {
      throw Exception('ObjectDisposedException(nameof(FakeService))');
    }

    disposed = true;
  }
}

class PocoClass {}
