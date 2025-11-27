import '../configuration/configuration.dart';

/// Factory to provide configuration for logger providers.
///
/// This interface allows logger providers to retrieve their specific
/// configuration from the application's configuration system. The factory
/// is responsible for extracting the relevant configuration section for
/// a given provider type.
abstract class ILoggerProviderConfigurationFactory {
  /// Gets the configuration for the specified logger provider type.
  ///
  /// The [providerType] parameter should be the Type of the logger provider
  /// (e.g., ConsoleLoggerProvider, DebugLoggerProvider).
  ///
  /// The factory will search for configuration sections matching either:
  /// - The full type name of the provider
  /// - The provider's alias (if defined via ProviderAlias attribute)
  ///
  /// Returns an [IConfiguration] containing the merged configuration from
  /// all matching sections.
  IConfiguration getConfiguration(Type providerType);
}

typedef LoggerProviderConfigurationFactory
    = ILoggerProviderConfigurationFactory;
