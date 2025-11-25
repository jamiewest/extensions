import 'package:extensions/configuration.dart';
import 'package:extensions/dependency_injection.dart';
import 'package:extensions/hosting.dart';
import 'package:extensions/logging.dart';
import 'package:extensions/options.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../options/fake_options.dart';

void main() {
  group('HostBuilderTests', () {
    test('DefaultConfigIsMutable', () {
      var host = DefaultHostBuilder().build();

      var config = host.services.getRequiredService<Configuration>();
      config['key1'] = 'value';
      expect(config['key1'], equals('value'));
    });

    test('ConfigureHostConfigurationPropagated', () {
      var hostBuilder = DefaultHostBuilder()
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

      var config = host.services.getRequiredService<Configuration>();
      expect(config['key1'], 'value1');
      expect(config['key2'], 'value3');
    });

    test('CanConfigureAppConfigurationAndRetrieveFromDI', () {
      var hostBuilder = DefaultHostBuilder()
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
      var config = host.services.getRequiredService<Configuration>();
      expect(config, isNotNull);
      expect('value1', config['key1']);
      expect('value3', config['key2']);
    });

    test('ConfigBasedSettingsConfigBasedOverride', () {
      var settings = <String, String>{
        HostDefaults.environmentKey: 'EnvA',
      };

      var config = ConfigurationBuilder()
          .addInMemoryCollection(settings.entries)
          .build();

      var overrideSettings = <String, String>{
        HostDefaults.environmentKey: 'EnvB'
      };

      var overrideConfig = ConfigurationBuilder()
          .addInMemoryCollection(overrideSettings.entries)
          .build();

      var hostBuilder = DefaultHostBuilder()
        ..configureHostConfiguration(
          (configBuilder) => configBuilder.addConfiguration(config),
        ).configureHostConfiguration(
          (configBuilder) => configBuilder.addConfiguration(overrideConfig),
        );

      var host = hostBuilder.build();

      expect(
        host.services.getRequiredService<HostEnvironment>().environmentName,
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

      var host = DefaultHostBuilder()
          .configureHostConfiguration(
            (configBuilder) => configBuilder.addConfiguration(config),
          )
          .useEnvironment(expected)
          .build();

      expect(
        host.services.getRequiredService<HostEnvironment>().environmentName,
        equals(expected),
      );
    });

    test('UseBasePathConfiguresBasePath', () {
      var vals = <String, String>{
        'ENV': 'Dev',
      };

      var builder = ConfigurationBuilder().addInMemoryCollection(vals.entries);
      var config = builder.build();

      var host = DefaultHostBuilder()
          .configureHostConfiguration(
              (configBuilder) => configBuilder.addConfiguration(config))
          .useContentRoot('/')
          .build();

      expect(
        host.services.getRequiredService<HostEnvironment>().contentRootPath,
        equals('/'),
      );
    });

    test('HostConfigParametersReadCorrectly', () {
      var parameters = <String, String>{
        'applicationName': 'MyProjectReference',
        'environment': Environments.development,
        'contentRoot': p.absolute('.'),
      };

      var host = DefaultHostBuilder()
          .configureHostConfiguration(
            (config) => config.addInMemoryCollection(parameters.entries),
          )
          .build();

      var env = host.services.getRequiredService<HostEnvironment>();

      expect(env.applicationName, equals('MyProjectReference'));
      expect(env.environmentName, equals(Environments.development));
      expect(env.contentRootPath, equals(p.absolute('.')));
    });

    test('RelativeContentRootIsResolved', () {
      var host = DefaultHostBuilder().useContentRoot('testroot').build();

      var basePath =
          host.services.getRequiredService<HostEnvironment>().contentRootPath;

      expect(p.isAbsolute(basePath), isTrue);
      expect(basePath, endsWith('${p.separator}testroot'));
    });

    test('DefaultContentRootIsApplicationBasePath', () {
      var host = DefaultHostBuilder().build();

      var appBase = p.current;
      expect(
        host.services.getRequiredService<HostEnvironment>().contentRootPath,
        equals(appBase),
      );
    });

    test('DefaultServicesAreAvailable', () {
      var host = DefaultHostBuilder().build();

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
      var hostBuilder = DefaultHostBuilder();

      var host = hostBuilder.build();
      expect(host.services.getService<LoggerFactory>(), isNotNull);
    });

    test('MultipleConfigureLoggingInvokedInOrder', () {
      var callCount = 0;
      DefaultHostBuilder()
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
      DefaultHostBuilder()
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
      var hostBuilder = DefaultHostBuilder()
          .configureServices((context, services) {
            services
              ..addTransient<_ServiceD>((s) => _ServiceD())
              ..addScoped<_ServiceC>(
                (s) => _ServiceC(
                  s.getRequiredService<_ServiceD>(),
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
      DefaultHostBuilder()
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
          DefaultHostBuilder().configureServices((hostContext, services) {
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
