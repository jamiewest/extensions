import 'package:extensions/hosting.dart';
import 'package:extensions/src/common/exceptions/object_disposed_exception.dart';
import 'package:extensions/src/dependency_injection/service_lookup/service_cache_key.dart';
import 'package:extensions/src/dependency_injection/service_lookup/service_identifier.dart';
import 'package:extensions/src/dependency_injection/service_lookup/service_lookup.dart';
import 'package:test/test.dart';

import '../hosting/fakes/fake_service.dart';

void main() {
  group('ServiceProviderEngineScopeTests', () {
    test('DoubleDisposeWorks', () {
      var provider = DefaultServiceProvider(
        ServiceCollection(),
        ServiceProviderOptions(),
      );

      var serviceProviderEngineScope =
          ServiceProviderEngineScope(provider, isRootScope: true);
      serviceProviderEngineScope.resolvedServices[ServiceCacheKey(
          ServiceIdentifier.fromServiceType(FakeService), 0)] = null;

      serviceProviderEngineScope
        ..dispose()
        ..dispose();
    });

    test('RootEngineScopeDisposeTest', () {
      var services = ServiceCollection();
      ServiceProvider sp = services.buildServiceProvider();
      var s = sp.getRequiredService<ServiceProvider>();
      (s as Disposable).dispose();

      expect(() => sp.getRequiredService<ServiceProvider>(),
          throwsA(TypeMatcher<ObjectDisposedException>()));
    });
  });
}
