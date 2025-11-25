import 'package:extensions/src/system/disposable.dart';

class FakeServiceImplementation implements FakeEveryService, Disposable {
  FakeServiceImplementation() : disposed = false;
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

abstract class FakeService {}

abstract class FakeEveryService implements FakeService {}

class PocoClass {}
