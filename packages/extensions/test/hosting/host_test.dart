import 'package:extensions/configuration.dart';
import 'package:extensions/dependency_injection.dart';
import 'package:extensions/hosting.dart';
import 'package:extensions/system.dart' hide equals;
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('HostTests', () {
    test('StopAsyncWithCancellation', () async {
      final builder = DefaultHostBuilder();
      final host = builder.build();
      await host.start();
      final cts = CancellationTokenSource()..cancel();
      expect(cts.isCancellationRequested, equals(true));
      await host.stop(cts.token);
    });

    test('CreateDefaultBuilder_IncludesContentRootByDefault', () {
      var expected = p.current;
      var builder = Host.createDefaultBuilder();
      var host = builder.build();
      var config = host.services.getRequiredService<Configuration>();
      expect(config['ContentRoot'], equals(expected));
      var env = host.services.getRequiredService<HostEnvironment>();
      expect(env.contentRootPath, equals(expected));
    });

    test('CreateDefaultBuilder_EnablesScopeValidation', () {
      var host = (Host.createDefaultBuilder()
            ..useEnvironment(Environments.development)
            ..configureServices(
              (context, services) => services.addScoped<ServiceA>(
                (sp) => ServiceA(),
              ),
            ))
          .build();

      expect(
        () => host.services.getRequiredService<ServiceA>(),
        throwsException,
      );
    });
  });
}

class ServiceA {}

class ServiceB {
  // ignore: avoid_unused_constructor_parameters
  ServiceB(ServiceC c);
}

class ServiceC {}

//     test('HostInjectsHostingEnvironment', () async {
//       var host =
//           _createBuilder().useEnvironment('WithHostingEnvironment').build();

//       await host.start();
//       var env = host.services.getRequiredService<HostEnvironment>();
//       expect(env.environmentName, equals('WithHostingEnvironment'));
//     });

//     test('CanCreateApplicationServicesWithAddedServices', () {
//       var host = _createBuilder()
//           .configureServices(
//             (hostContext, services) => services.addSingleton<FakeService>(
//               (_) => FakeServiceImplementation(),
//             ),
//           )
//           .build();

//       expect(host.services.getRequiredService<FakeService>(), isNotNull);
//     });

//     test('EnvDefaultsToProductionIfNoConfig', () {
//       var host = _createBuilder().build();
//       var env = host.services.getRequiredService<HostEnvironment>();
//       expect(env.environmentName, equals(Environments.production));
//     });

//     test('EnvDefaultsToConfigValueIfSpecified', () {
//       var vals = <String, String>{
//         'Environment': Environments.staging,
//       };

//       var builder = ConfigurationBuilder()
//        .addInMemoryCollection(vals.entries);
//       var config = builder.build();

//       var host = _createBuilder(config).build();
//       var env = host.services.getRequiredService<HostEnvironment>();
//       expect(env.environmentName, equals(Environments.staging));
//     });

//     test('IsEnvironmentExtensionIsCaseInsensitive', () async {
//       var host = _createBuilder().build();
//       await host.start();
//       var env = host.services.getRequiredService<HostEnvironment>();
//       expect(env.isEnvironment(Environments.production), isTrue);
//       expect(env.isEnvironment('producTion'), isTrue);
//     });

//     test('HostCanBeStarted', () {
//       FakeHostedService service;
//       var host = _createBuilder()
//           .configureServices(
//             (context, services) => services.addSingleton<HostedService>(
//               (_) => FakeHostedService(),
//             ),
//           )
//           .startSync();

//       service = host.services.getRequiredService<HostedService>()
//           as FakeHostedService;

//       expect(host, isNotNull);
//       expect(service.startCount, equals(1));
//       expect(service.stopCount, equals(0));
//       expect(service.disposeCount, equals(0));

//       //host.stop();
//       expect(service.startCount, equals(1));
//       //expect(service.stopCount, equals(0));
//       //expect(service.disposeCount, equals(1));
//     });
//   });
// }

// HostBuilder _createBuilder([Configuration? config]) =>
//     HostBuilder().configureHostConfiguration(
//       (builder) => builder.addConfiguration(
//         config ?? ConfigurationBuilder().build(),
//       ),
//     );
