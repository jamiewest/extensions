import '../../dependency_injection.dart';
import '../configuration/configuration.dart';
import 'i_logger_provider_configuration_factory.dart';
import 'logger_provider_configuration_factory.dart';
import 'logging_builder.dart';

/// Extension methods for configuring logging from [IConfiguration].
extension LoggingBuilderConfigurationExtensions on LoggingBuilder {
  /// Adds services required to consume [ILoggerProviderConfigurationFactory].
  ///
  /// This method registers the configuration factory that allows logger
  /// providers to retrieve their specific configuration from the application's
  /// configuration system.
  ///
  /// Example:
  /// ```dart
  /// services.addLogging((logging) {
  ///   logging.addConfiguration(hostContext.configuration);
  /// });
  /// ```
  ///
  /// After calling this method, logger providers can inject
  /// [ILoggerProviderConfigurationFactory] to access their configuration.
  LoggingBuilder addConfiguration(IConfiguration configuration) {
    // Register the configuration factory as a singleton
    services.tryAddSingleton<ILoggerProviderConfigurationFactory>(
      (sp) => LoggerProviderConfigurationFactoryImpl([configuration]),
    );

    return this;
  }

  /// Adds services required to consume [ILoggerProviderConfigurationFactory]
  /// from multiple configuration sources.
  ///
  /// This overload allows you to provide multiple configuration sources that
  /// will be merged when retrieving provider-specific configuration. Later
  /// sources take precedence over earlier ones.
  ///
  /// Example:
  /// ```dart
  /// services.addLogging((logging) {
  ///   logging.addConfigurations([
  ///     baseConfiguration,
  ///     environmentConfiguration,
  ///   ]);
  /// });
  /// ```
  LoggingBuilder addConfigurations(Iterable<IConfiguration> configurations) {
    // Register the configuration factory with multiple sources
    services.tryAddSingleton<ILoggerProviderConfigurationFactory>(
      (sp) => LoggerProviderConfigurationFactoryImpl(configurations),
    );

    return this;
  }
}
