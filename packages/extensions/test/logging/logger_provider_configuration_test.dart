import 'package:extensions/configuration.dart';
import 'package:extensions/logging.dart';
import 'package:test/test.dart';

// Test provider types
class ConsoleLoggerProvider {}

class DebugLoggerProvider {}

class FileLoggerProvider {}

void main() {
  group('LoggerProviderConfigurationFactory', () {
    test('returns configuration for provider with alias', () {
      // Arrange
      final config = ConfigurationBuilder()
        ..addInMemoryCollection(
          <String, String>{
            'Logging:Console:LogLevel:Default': 'Debug',
            'Logging:Console:IncludeScopes': 'true',
          }.entries,
        );

      final builtConfig = config.build();
      final factory = LoggerProviderConfigurationFactoryImpl([builtConfig]);

      // Act
      final providerConfig = factory.getConfiguration(ConsoleLoggerProvider);

      // Assert
      expect(providerConfig['LogLevel:Default'], equals('Debug'));
      expect(providerConfig['IncludeScopes'], equals('true'));
    });

    test('returns configuration for provider with full type name', () {
      // Arrange
      final config = ConfigurationBuilder()
        ..addInMemoryCollection(
          <String, String>{
            'Logging:ConsoleLoggerProvider:LogLevel:Default': 'Warning',
          }.entries,
        );

      final builtConfig = config.build();
      final factory = LoggerProviderConfigurationFactoryImpl([builtConfig]);

      // Act
      final providerConfig = factory.getConfiguration(ConsoleLoggerProvider);

      // Assert
      expect(providerConfig['LogLevel:Default'], equals('Warning'));
    });

    test('merges configuration from alias and full type name', () {
      // Arrange
      final config = ConfigurationBuilder()
        ..addInMemoryCollection(
          <String, String>{
            'Logging:Console:LogLevel:Default': 'Debug',
            'Logging:ConsoleLoggerProvider:LogLevel:MyApp': 'Information',
          }.entries,
        );

      final builtConfig = config.build();
      final factory = LoggerProviderConfigurationFactoryImpl([builtConfig]);

      // Act
      final providerConfig = factory.getConfiguration(ConsoleLoggerProvider);

      // Assert
      expect(providerConfig['LogLevel:Default'], equals('Debug'));
      expect(providerConfig['LogLevel:MyApp'], equals('Information'));
    });

    test('merges configuration from multiple sources', () {
      // Arrange
      final config1 = ConfigurationBuilder()
        ..addInMemoryCollection(
          <String, String>{
            'Logging:Console:LogLevel:Default': 'Debug',
          }.entries,
        );

      final config2 = ConfigurationBuilder()
        ..addInMemoryCollection(
          <String, String>{
            'Logging:Console:LogLevel:MyApp': 'Information',
          }.entries,
        );

      final factory = LoggerProviderConfigurationFactoryImpl([
        config1.build(),
        config2.build(),
      ]);

      // Act
      final providerConfig = factory.getConfiguration(ConsoleLoggerProvider);

      // Assert
      expect(providerConfig['LogLevel:Default'], equals('Debug'));
      expect(providerConfig['LogLevel:MyApp'], equals('Information'));
    });

    test('returns empty configuration when no matching sections found', () {
      // Arrange
      final config = ConfigurationBuilder()
        ..addInMemoryCollection(
          <String, String>{
            'Logging:Debug:LogLevel:Default': 'Debug',
          }.entries,
        );

      final builtConfig = config.build();
      final factory = LoggerProviderConfigurationFactoryImpl([builtConfig]);

      // Act
      final providerConfig = factory.getConfiguration(ConsoleLoggerProvider);

      // Assert
      expect(providerConfig['LogLevel:Default'], isNull);
      expect(providerConfig.getChildren(), isEmpty);
    });

    test('handles nested configuration sections', () {
      // Arrange
      final config = ConfigurationBuilder()
        ..addInMemoryCollection(
          <String, String>{
            'Logging:File:Path': '/var/log/app.log',
            'Logging:File:MaxSizeInBytes': '10485760',
            'Logging:File:RetainedFileCount': '7',
          }.entries,
        );

      final builtConfig = config.build();
      final factory = LoggerProviderConfigurationFactoryImpl([builtConfig]);

      // Act
      final providerConfig = factory.getConfiguration(FileLoggerProvider);

      // Assert
      expect(providerConfig['Path'], equals('/var/log/app.log'));
      expect(providerConfig['MaxSizeInBytes'], equals('10485760'));
      expect(providerConfig['RetainedFileCount'], equals('7'));
    });
  });

  group('LoggerProviderConfiguration', () {
    test('retrieves configuration for specific provider type', () {
      // Arrange
      final config = ConfigurationBuilder()
        ..addInMemoryCollection(
          <String, String>{
            'Logging:Console:LogLevel:Default': 'Debug',
          }.entries,
        );

      final builtConfig = config.build();
      final factory = LoggerProviderConfigurationFactoryImpl([builtConfig]);
      final providerConfig =
          LoggerProviderConfigurationImpl<ConsoleLoggerProvider>(factory);

      // Act
      final configuration = providerConfig.configuration;

      // Assert
      expect(configuration['LogLevel:Default'], equals('Debug'));
    });

    test('different provider types get different configurations', () {
      // Arrange
      final config = ConfigurationBuilder()
        ..addInMemoryCollection(
          <String, String>{
            'Logging:Console:LogLevel:Default': 'Debug',
            'Logging:Debug:LogLevel:Default': 'Information',
          }.entries,
        );

      final builtConfig = config.build();
      final factory = LoggerProviderConfigurationFactoryImpl([builtConfig]);

      final consoleConfig =
          LoggerProviderConfigurationImpl<ConsoleLoggerProvider>(factory);
      final debugConfig =
          LoggerProviderConfigurationImpl<DebugLoggerProvider>(factory);

      // Act & Assert
      expect(
        consoleConfig.configuration['LogLevel:Default'],
        equals('Debug'),
      );
      expect(
        debugConfig.configuration['LogLevel:Default'],
        equals('Information'),
      );
    });
  });
}
