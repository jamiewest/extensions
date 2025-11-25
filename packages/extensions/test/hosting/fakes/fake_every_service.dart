import 'fake_scoped_service.dart';
import 'fake_service_instance.dart';
import 'fake_singleton_service.dart';

abstract class FakeEveryService
    implements FakeScopedService, FakeServiceInstance, FakeSingletonService {}
