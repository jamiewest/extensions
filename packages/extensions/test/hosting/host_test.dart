import 'package:extensions/hosting.dart';
import 'package:extensions/src/primitives/cancellation_token.dart';
import 'package:test/test.dart';

import 'fakes/fake_hosted_service.dart';
import 'fakes/fake_service.dart';
import 'fakes/fake_service_implementation.dart';

void main() {
  group('HostTests', () {
    test('StopAsyncWithCancellation', () async {
      final builder = HostBuilder();
      final host = builder.build();
      await host.start();
      final cts = CancellationTokenSource()..cancel();
      expect(cts.isCancellationRequested, equals(true));
      await host.stop(cts.token);
    });

    test('HostInjectsHostingEnvironment', () async {
      var host =
          _createBuilder().useEnvironment('WithHostingEnvironment').build();

      await host.start();
      var env = host.services.getService<HostEnvironment>();
      expect(env.environmentName, equals('WithHostingEnvironment'));
    });

    test('CanCreateApplicationServicesWithAddedServices', () {
      var host = _createBuilder()
          .configureServices(
            (hostContext, services) => services.addSingleton<FakeService>(
              implementationInstance: FakeServiceImplementation(),
            ),
          )
          .build();

      expect(host.services.getRequiredService<FakeService>(), isNotNull);
    });

    test('EnvDefaultsToProductionIfNoConfig', () {
      var host = _createBuilder().build();
      var env = host.services.getService<HostEnvironment>();
      expect(env.environmentName, equals(Environments.production));
    });

    test('EnvDefaultsToConfigValueIfSpecified', () {
      var vals = <String, String>{
        'Environment': Environments.staging,
      };

      var builder = ConfigurationBuilder().addInMemoryCollection(vals.entries);
      var config = builder.build();

      var host = _createBuilder(config).build();
      var env = host.services.getService<HostEnvironment>();
      expect(env.environmentName, equals(Environments.staging));
    });

    test('IsEnvironmentExtensionIsCaseInsensitive', () async {
      var host = _createBuilder().build();
      await host.start();
      var env = host.services.getRequiredService<HostEnvironment>();
      expect(env.isEnvironment(Environments.production), isTrue);
      expect(env.isEnvironment('producTion'), isTrue);
    });

    test('HostCanBeStarted', () {
      FakeHostedService service;
      var host = _createBuilder()
          .configureServices(
            (context, services) => services.addSingleton<HostedService>(
              implementationInstance: FakeHostedService(),
            ),
          )
          .startSync();

      service = host.services.getRequiredService<HostedService>()
          as FakeHostedService;

      expect(host, isNotNull);
      expect(service.startCount, equals(1));
      expect(service.stopCount, equals(0));
      expect(service.disposeCount, equals(0));

      host.stop();
      expect(service.startCount, equals(1));
      expect(service.stopCount, equals(0));
      expect(service.disposeCount, equals(1));
    });
  });
}

HostBuilder _createBuilder([Configuration? config]) =>
    HostBuilder().configureHostConfiguration(
      (builder) => builder.addConfiguration(
        config ?? ConfigurationBuilder().build(),
      ),
    );
