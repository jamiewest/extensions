import 'package:extensions/hosting.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../options/fake_options.dart';

void main() {
  group('HostBuilderTests', () {
    test('DefaultConfigIsMutable', () {
      var host = HostBuilder().build();

      var config =
          host.services.getRequiredService<Configuration>() as Configuration;
      config['key1'] = 'value';
      expect(config['key1'], equals('value'));
    });

    test('ConfigureHostConfigurationPropagated', () {
      var hostBuilder = HostBuilder()
        ..configureHostConfiguration(
          (configBuilder) => configBuilder.addInMemoryCollection(
            <String, String>{'key1': 'value1'}.entries,
          ),
        )
        ..configureHostConfiguration(
          (configBuilder) => configBuilder.addInMemoryCollection(
            <String, String>{'key2': 'value2'}.entries,
          ),
        )
        ..configureHostConfiguration(
          (configBuilder) => configBuilder.addInMemoryCollection(
            <String, String>{'key2': 'value3'}.entries,
          ),
        )
        ..configureAppConfiguration((context, configBuilder) {
          expect(context.configuration!['key1'], 'value1');
          expect(context.configuration!['key2'], 'value3');
          var config = configBuilder.build();
          expect(config['key1'], 'value1');
          expect(config['key2'], 'value3');
        });

      var host = hostBuilder.build();

      var config =
          host.services.getRequiredService<Configuration>() as Configuration;
      expect(config['key1'], 'value1');
      expect(config['key2'], 'value3');
    });

    test('CanConfigureAppConfigurationAndRetrieveFromDI', () {
      var hostBuilder = HostBuilder()
        ..configureAppConfiguration(
          (context, configBuilder) => configBuilder.addInMemoryCollection(
            <String, String>{'key1': 'value1'}.entries,
          ),
        )
        ..configureAppConfiguration(
          (context, configBuilder) => configBuilder.addInMemoryCollection(
            <String, String>{'key2': 'value2'}.entries,
          ),
        )
        ..configureAppConfiguration(
          (context, configBuilder) => configBuilder.addInMemoryCollection(
            <String, String>{'key2': 'value3'}.entries,
          ),
        );

      var host = hostBuilder.build();
      var config =
          host.services.getRequiredService<Configuration>() as Configuration;
      expect(config, isNotNull);
      expect('value1', config['key1']);
      expect('value3', config['key2']);
    });

    test('ConfigBasedSettingsConfigBasedOverride', () {
      var settings = <String, String>{
        environmentKey: 'EnvA',
      };

      var config = ConfigurationBuilder()
          .addInMemoryCollection(settings.entries)
          .build();

      var overrideSettings = <String, String>{environmentKey: 'EnvB'};

      var overrideConfig = ConfigurationBuilder()
          .addInMemoryCollection(overrideSettings.entries)
          .build();

      var hostBuilder = HostBuilder()
        ..configureHostConfiguration(
          (configBuilder) => configBuilder.addConfiguration(config),
        ).configureHostConfiguration(
          (configBuilder) => configBuilder.addConfiguration(overrideConfig),
        );

      var host = hostBuilder.build();

      expect(
        (host.services.getRequiredService<HostEnvironment>() as HostEnvironment)
            .environmentName,
        equals('EnvB'),
      );
    });

    test('UseEnvironmentIsNotOverriden', () {
      var vals = <String, String>{
        'ENV': 'Dev',
      };

      var builder = ConfigurationBuilder().addInMemoryCollection(vals.entries);
      var config = builder.build();

      var expected = 'MY_TEST_ENVIRONMENT';

      var host = HostBuilder()
          .configureHostConfiguration(
            (configBuilder) => configBuilder.addConfiguration(config),
          )
          .useEnvironment(expected)
          .build();

      expect(
        (host.services.getRequiredService<HostEnvironment>() as HostEnvironment)
            .environmentName,
        equals(expected),
      );
    });

    test('UseBasePathConfiguresBasePath', () {
      var vals = <String, String>{
        'ENV': 'Dev',
      };

      var builder = ConfigurationBuilder().addInMemoryCollection(vals.entries);
      var config = builder.build();

      var host = HostBuilder()
          .configureHostConfiguration(
              (configBuilder) => configBuilder.addConfiguration(config))
          .useContentRoot('/')
          .build();

      expect(
        (host.services.getRequiredService<HostEnvironment>() as HostEnvironment)
            .contentRootPath,
        equals('/'),
      );
    });

    test('HostConfigParametersReadCorrectly', () {
      var parameters = <String, String>{
        'applicationName': 'MyProjectReference',
        'environment': Environments.development,
        'contentRoot': p.absolute('.'),
      };

      var host = HostBuilder()
          .configureHostConfiguration(
            (config) => config.addInMemoryCollection(parameters.entries),
          )
          .build();

      var env = host.services.getRequiredService<HostEnvironment>()
          as HostEnvironment;

      expect(env.applicationName, equals('MyProjectReference'));
      expect(env.environmentName, equals(Environments.development));
      expect(env.contentRootPath, equals(p.absolute('.')));
    });

    test('RelativeContentRootIsResolved', () {
      var host = HostBuilder().useContentRoot('testroot').build();

      var basePath = (host.services.getRequiredService<HostEnvironment>()
              as HostEnvironment)
          .contentRootPath;

      expect(p.isAbsolute(basePath!), isTrue);
      expect(basePath, endsWith('${p.separator}testroot'));
    });

    test('DefaultContentRootIsApplicationBasePath', () {
      var host = HostBuilder().build();

      var appBase = p.current;
      expect(
        (host.services.getRequiredService<HostEnvironment>() as HostEnvironment)
            .contentRootPath,
        equals(appBase),
      );
    });

    test('DefaultServicesAreAvailable', () {
      var host = HostBuilder().build();

      expect(host.services.getRequiredService<HostingEnvironment>(), isNotNull);
      expect(host.services.getRequiredService<HostEnvironment>(), isNotNull);
      expect(host.services.getRequiredService<Configuration>(), isNotNull);
      expect(host.services.getRequiredService<HostBuilderContext>(), isNotNull);
      expect(
          host.services.getRequiredService<ApplicationLifetime>(), isNotNull);
      expect(host.services.getRequiredService<HostApplicationLifetime>(),
          isNotNull);
      expect(host.services.getRequiredService<LoggerFactory>(), isNotNull);

      // Getting an IEnumerable from getRequiredService is not supported,
      // need to use getServices to satisfy the test.
      // Assert.NotNull(host.Services.GetRequiredService
      // <IOptions<FakeOptions>>());
      expect(host.services.getServices<Options<FakeOptions>>(), isNotNull);
    });

    test('DefaultCreatesLoggerFactory', () {
      var hostBuilder = HostBuilder();

      var host = hostBuilder.build();
      expect(host.services.getService<LoggerFactory>(), isNotNull);
    });

    test('MultipleConfigureLoggingInvokedInOrder', () {
      var callCount = 0;
      HostBuilder()
          .configureLogging(
            (hostContext, loggerFactory) => expect(
              callCount++,
              equals(0),
            ),
          )
          .configureLogging(
            (hostContext, loggerFactory) => expect(
              callCount++,
              equals(1),
            ),
          )
          .build();

      expect(callCount, equals(2));
    });

    test('HostingContextContainsAppConfigurationDuringConfigureServices', () {
      HostBuilder()
          .configureAppConfiguration(
            (context, configBuilder) => configBuilder.addInMemoryCollection(
                <String, String>{'key1': 'value1'}.entries),
          )
          .configureServices(
            (context, factory) => expect(
              context.configuration!['key1'],
              equals('value1'),
            ),
          )
          .build();
    });

    test('ConfigureDefaultServiceProvider', () {
      var hostBuilder = HostBuilder()
          .configureServices((context, services) {
            services
              ..addTransient<_ServiceD, _ServiceD>((s) => _ServiceD())
              ..addScoped<_ServiceC, _ServiceC>(
                (s) => _ServiceC(
                  s.getRequiredService<_ServiceD>() as _ServiceD,
                ),
              );
          })
          .configureHostConfiguration(
            (configuration) => configuration.addInMemoryCollection(
              <String, String>{'Key': 'Value'}.entries,
            ),
          )
          .useDefaultServiceProvider((context, options) {
            expect(context, isNotNull);
            expect(context.configuration!['Key'], equals('Value'));
            expect(options, isNotNull);
            options.validateScopes = true;
          });

      var host = hostBuilder.build();
      expect(
          () => host.services.getRequiredService<_ServiceC>(), throwsException);
    });

    test('HostingContextContainsAppConfigurationDuringConfigureLogging', () {
      HostBuilder()
          .configureAppConfiguration(
        (context, configBuilder) => configBuilder.addInMemoryCollection(
          <String, String>{'key1': 'value1'}.entries,
        ),
      )
          .configureLogging((context, factory) {
        expect(context.configuration!['key1'], equals('value1'));
      }).build();
    });

    test('BuilderPropertiesAreAvailableInBuilderAndContext', () {
      var hostBuilder =
          HostBuilder().configureServices((hostContext, services) {
        expect(hostContext.properties['key'], equals('value'));
      });

      hostBuilder.properties['key'] = 'value';

      expect(hostBuilder.properties['key'], equals('value'));

      hostBuilder.build();
    });
  });
}

class _ServiceC {
  final _ServiceD serviceD;

  _ServiceC(this.serviceD);
}

class _ServiceD {}
