// ignore_for_file: avoid_print

import 'package:extensions/configuration.dart';
import 'package:extensions/dependency_injection.dart';
import 'package:extensions/logging.dart';

/// This example demonstrates the logging configuration system that achieves
/// parity with .NET's Microsoft.Extensions.Logging.Configuration.
///
/// Key features demonstrated:
/// - Provider-specific configuration using aliases
/// - Configuration factory for retrieving provider settings
/// - Hierarchical configuration with colon-separated keys
/// - Multiple configuration source merging
void main() {
  print('=== Logging Configuration Example ===\n');

  // Example 1: Basic provider configuration using aliases
  print('Example 1: Provider configuration with aliases');
  basicProviderConfiguration();
  print('');

  // Example 2: Provider configuration using full type names
  print('Example 2: Provider configuration with full type names');
  fullTypeNameConfiguration();
  print('');

  // Example 3: Merging multiple configuration sources
  print('Example 3: Merging multiple configuration sources');
  multipleConfigurationSources();
  print('');

  // Example 4: Nested provider-specific settings
  print('Example 4: Nested provider-specific settings');
  nestedProviderSettings();
  print('');

  // Example 5: Using configuration factory directly
  print('Example 5: Using configuration factory directly');
  usingConfigurationFactory();
  print('');
}

/// Example 1: Configure logging providers using their aliases.
///
/// Providers follow the naming convention *LoggerProvider, where the
/// prefix before "LoggerProvider" becomes the alias. For example:
/// - ConsoleLoggerProvider -> alias: "Console"
/// - DebugLoggerProvider -> alias: "Debug"
void basicProviderConfiguration() {
  // Create configuration with provider-specific settings
  final config = ConfigurationBuilder()
    ..addInMemoryCollection(
      <String, String>{
        // Global logging settings
        'Logging:LogLevel:Default': 'Information',
        'Logging:IncludeScopes': 'true',

        // Console provider settings (using alias "Console")
        'Logging:Console:LogLevel:Default': 'Debug',
        'Logging:Console:LogLevel:MyApp': 'Trace',

        // Debug provider settings (using alias "Debug")
        'Logging:Debug:LogLevel:Default': 'Warning',
      }.entries,
    );

  final builtConfig = config.build();

  // Set up logging with configuration
  final services = ServiceCollection()
    ..addLogging((logging) {
      logging
        ..addConfiguration(builtConfig)
        ..addSimpleConsole()
        ..addDebug();
    });

  final provider = services.buildServiceProvider();
  final loggerFactory = provider.getRequiredService<LoggerFactory>();
  final logger = loggerFactory.createLogger('MyApp')
    ..logInformation('Logging configured with provider-specific settings');
  print('✓ Provider configuration applied successfully');
}

/// Example 2: Configure providers using their full type names.
///
/// In addition to aliases, providers can be configured using their
/// full type name (e.g., "ConsoleLoggerProvider").
void fullTypeNameConfiguration() {
  final config = ConfigurationBuilder()
    ..addInMemoryCollection(
      <String, String>{
        // Using full type name instead of alias
        'Logging:ConsoleLoggerProvider:LogLevel:Default': 'Debug',
        'Logging:DebugLoggerProvider:LogLevel:Default': 'Information',
      }.entries,
    );

  final builtConfig = config.build();
  final factory = LoggerProviderConfigurationFactoryImpl([builtConfig]);

  // Retrieve configuration for specific provider type
  final consoleConfig = factory.getConfiguration(ConsoleLoggerProvider);

  print(
    'Console provider LogLevel:Default = '
    '${consoleConfig['LogLevel:Default']}',
  );
  print('✓ Full type name configuration works correctly');
}

/// Example 3: Merge configuration from multiple sources.
///
/// When multiple configuration sources are provided, they are merged
/// with later sources taking precedence.
void multipleConfigurationSources() {
  // Base configuration
  final baseConfig = ConfigurationBuilder()
    ..addInMemoryCollection(
      <String, String>{
        'Logging:Console:LogLevel:Default': 'Information',
        'Logging:Console:LogLevel:MyApp': 'Debug',
      }.entries,
    );

  // Environment-specific configuration (overrides)
  final envConfig = ConfigurationBuilder()
    ..addInMemoryCollection(
      <String, String>{
        'Logging:Console:LogLevel:Default': 'Warning', // Overrides base
        'Logging:Console:LogLevel:System': 'Error', // Adds new setting
      }.entries,
    );

  // Create factory with multiple sources
  final factory = LoggerProviderConfigurationFactoryImpl([
    baseConfig.build(),
    envConfig.build(),
  ]);

  final consoleConfig = factory.getConfiguration(ConsoleLoggerProvider);

  print('Default level (overridden): ${consoleConfig['LogLevel:Default']}');
  print('MyApp level (from base): ${consoleConfig['LogLevel:MyApp']}');
  print('System level (from env): ${consoleConfig['LogLevel:System']}');
  print('✓ Multiple configuration sources merged successfully');
}

/// Example 4: Provider-specific nested settings.
///
/// Providers can have complex nested configuration beyond just log levels.
void nestedProviderSettings() {
  final config = ConfigurationBuilder()
    ..addInMemoryCollection(
      <String, String>{
        // File provider with multiple settings
        'Logging:File:Path': '/var/log/app.log',
        'Logging:File:MaxSizeInBytes': '10485760',
        'Logging:File:RetainedFileCount': '7',
        'Logging:File:LogLevel:Default': 'Information',
      }.entries,
    );

  final builtConfig = config.build();
  final factory = LoggerProviderConfigurationFactoryImpl([builtConfig]);

  // Hypothetical FileLoggerProvider
  final fileConfig = factory.getConfiguration(FileLoggerProvider);

  print('File path: ${fileConfig['Path']}');
  print('Max size: ${fileConfig['MaxSizeInBytes']} bytes');
  print('Retained files: ${fileConfig['RetainedFileCount']}');
  print('Log level: ${fileConfig['LogLevel:Default']}');
  print('✓ Nested provider settings retrieved successfully');
}

/// Example 5: Using the configuration factory directly.
///
/// Logger providers can inject ILoggerProviderConfigurationFactory
/// to access their specific configuration at runtime.
void usingConfigurationFactory() {
  final config = ConfigurationBuilder()
    ..addInMemoryCollection(
      <String, String>{
        'Logging:Console:LogLevel:Default': 'Debug',
        'Logging:Console:IncludeScopes': 'true',
        'Logging:Console:TimestampFormat': 'yyyy-MM-dd HH:mm:ss',
      }.entries,
    );

  final builtConfig = config.build();

  // Register the configuration factory
  final services = ServiceCollection()
    ..addLogging((logging) {
      logging.addConfiguration(builtConfig);
    });

  final provider = services.buildServiceProvider();

  // Retrieve the factory from DI
  final factory =
      provider.getRequiredService<ILoggerProviderConfigurationFactory>();

  // Get provider-specific configuration
  final consoleConfig = factory.getConfiguration(ConsoleLoggerProvider);

  print('Console configuration retrieved:');
  print('  LogLevel:Default = ${consoleConfig['LogLevel:Default']}');
  print('  IncludeScopes = ${consoleConfig['IncludeScopes']}');
  print('  TimestampFormat = ${consoleConfig['TimestampFormat']}');
  print('✓ Configuration factory injected and used successfully');
}

/// Example provider types for demonstration.
class FileLoggerProvider {}
