import 'fake_every_service.dart';

class FakeServiceImplementation implements FakeEveryService {
  bool disposed = false;

  void dispose() {
    disposed = true;
  }
}
