import 'fake_service.dart';

abstract class FactoryService {
  FakeService? get fakeService;

  int? get value;
}

class TransientFactoryService implements FactoryService {
  @override
  FakeService? fakeService;

  @override
  int? value;
}
