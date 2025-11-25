import 'package:extensions/configuration.dart';
import 'package:extensions/dependency_injection.dart';
import 'package:extensions/hosting.dart';
import 'package:test/test.dart';

void main() {
  group('HostApplicationBuilderTests', () {
    test('DefaultConfigIsMutable', () {
      final builder = _createEmptyBuilder();

      builder.configuration['key1'] = 'value1';

      final host = builder.build();

      final config = host.services.getRequiredService<Configuration>();
      config['key2'] = 'value2';

      expect(config['key1'], equals('value1'));
      expect(config['key2'], equals('value2'));
    });

    test('CanConfigureAppConfigurationAndRetrieveFromDI', () {
      final builder = _createEmptyBuilder();

      builder.configuration.addInMemoryCollection(<String, String>{
        'key1': 'value1',
      }.entries);

      builder.configuration.addInMemoryCollection(<String, String>{
        'key2': 'value2',
      }.entries);

      final host = builder.build();

      final config = host.services.getRequiredService<Configuration>();

      expect(config, isNotNull);
      expect(config['key1'], equals('value1'));
      expect(config['key2'], equals('value2'));

      builder.configuration.addInMemoryCollection(<String, String>{
        'key2': 'value3',
      }.entries);

      expect(config['key1'], equals('value1'));
      expect(config['key2'], equals('value3'));
    });

    test('ConfigurationSettingCanInfluenceEnvironment', () {
      final config = ConfigurationManager()
        ..addInMemoryCollection(
          <String, String>{
            HostDefaults.applicationKey: 'AppA',
            HostDefaults.environmentKey: 'EnvA',
          }.entries,
        );

      final builder = HostApplicationBuilder(
        settings: HostApplicationBuilderSettings()
          ..disableDefaults = true
          ..configuration = config,
      );

      expect(
          builder.configuration[HostDefaults.applicationKey], equals('AppA'));
      expect(
          builder.configuration[HostDefaults.environmentKey], equals('EnvA'));

      expect(builder.environment.applicationName, equals('AppA'));
      expect(builder.environment.environmentName, equals('EnvA'));

      final host = builder.build();

      final hostEnvironmentFromServices =
          host.services.getRequiredService<HostEnvironment>();

      expect(hostEnvironmentFromServices.applicationName, equals('AppA'));
      expect(hostEnvironmentFromServices.environmentName, equals('EnvA'));
    });

    test('DirectSetttingsOverrideConfigurationSetting', () {
      final config = ConfigurationManager()
        ..addInMemoryCollection(
          <String, String>{
            HostDefaults.applicationKey: 'AppA',
            HostDefaults.environmentKey: 'EnvA',
          }.entries,
        );

      final builder = HostApplicationBuilder(
        settings: HostApplicationBuilderSettings()
          ..disableDefaults = true
          ..configuration = config
          ..applicationName = 'AppB'
          ..environmentName = 'EnvB',
      );

      expect(
          builder.configuration[HostDefaults.applicationKey], equals('AppB'));
      expect(
          builder.configuration[HostDefaults.environmentKey], equals('EnvB'));

      expect(builder.environment.applicationName, equals('AppB'));
      expect(builder.environment.environmentName, equals('EnvB'));

      final host = builder.build();

      final hostEnvironmentFromServices =
          host.services.getRequiredService<HostEnvironment>();

      expect(hostEnvironmentFromServices.applicationName, equals('AppB'));
      expect(hostEnvironmentFromServices.environmentName, equals('EnvB'));
    });

    test('ChangingConfigurationPostBuilderConsturctionDoesNotChangeEnvironment',
        () {
      final config = ConfigurationManager()
        ..addInMemoryCollection(
          <String, String>{
            HostDefaults.applicationKey: 'AppA',
            HostDefaults.environmentKey: 'EnvA',
          }.entries,
        );

      final builder = HostApplicationBuilder(
        settings: HostApplicationBuilderSettings()
          ..disableDefaults = true
          ..configuration = config,
      );

      config.addInMemoryCollection(
        <String, String>{
          HostDefaults.applicationKey: 'AppB',
          HostDefaults.environmentKey: 'EnvB',
        }.entries,
      );

      expect(
          builder.configuration[HostDefaults.applicationKey], equals('AppB'));
      expect(
          builder.configuration[HostDefaults.environmentKey], equals('EnvB'));

      expect(builder.environment.applicationName, equals('AppA'));
      expect(builder.environment.environmentName, equals('EnvA'));

      final host = builder.build();

      final hostEnvironmentFromServices =
          host.services.getRequiredService<HostEnvironment>();

      expect(hostEnvironmentFromServices.applicationName, equals('AppA'));
      expect(hostEnvironmentFromServices.environmentName, equals('EnvA'));
    });

    test('HostConfigParametersReadCorrectly', () {
      final parameters = <String, String>{
        'applicationName': 'MyProjectReference',
        'environment': Environments.development,
      };

      final config = ConfigurationManager()
        ..addInMemoryCollection(parameters.entries);

      final builder = HostApplicationBuilder(
        settings: HostApplicationBuilderSettings()
          ..disableDefaults = true
          ..configuration = config,
      );

      expect(builder.environment.applicationName, equals('MyProjectReference'));
      expect(builder.environment.environmentName,
          equals(Environments.development));

      final host = builder.build();

      final env = host.services.getRequiredService<HostEnvironment>();

      expect(env.applicationName, equals('MyProjectReference'));
      expect(env.environmentName, equals(Environments.development));
    });
  });
}

HostApplicationBuilder _createEmptyBuilder() => HostApplicationBuilder(
    settings: HostApplicationBuilderSettings()..disableDefaults = true);
