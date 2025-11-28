import '../configuration/configuration.dart';
import '../configuration/configuration_builder.dart';
import '../configuration/configuration_provider.dart';
import '../configuration/configuration_source.dart';
import 'i_logger_provider_configuration_factory.dart';
import 'provider_alias_utilities.dart';

/// Internal wrapper for a single logging configuration source.
class _LoggingConfiguration {
  final IConfiguration configuration;

  _LoggingConfiguration(this.configuration);
}

/// Factory implementation for providing configuration to logger providers.
///
/// This factory aggregates configuration from multiple sources and provides
/// provider-specific configuration based on the provider's type name or alias.
///
/// Configuration is searched in the following locations:
/// 1. Logging:{ProviderAlias}:*
/// 2. Logging:{ProviderFullName}:*
///
/// All matching sections are merged together with later sources taking
/// precedence.
class LoggerProviderConfigurationFactoryImpl
    implements ILoggerProviderConfigurationFactory {
  final List<_LoggingConfiguration> _configurations;

  /// Creates a new instance of [LoggerProviderConfigurationFactoryImpl].
  ///
  /// The [configurations] parameter contains all logging configuration sources
  /// that should be consulted when retrieving provider-specific configuration.
  LoggerProviderConfigurationFactoryImpl(
    Iterable<IConfiguration> configurations,
  ) : _configurations = configurations
            .map(_LoggingConfiguration.new)
            .toList(growable: false);

  @override
  IConfiguration getConfiguration(Type providerType) {
    ArgumentError.checkNotNull(providerType, 'providerType');

    // Get the provider's alias (e.g., "Console" from "ConsoleLoggerProvider")
    final alias = ProviderAliasUtilities.getAlias(providerType);

    // Get the full type name
    final fullName = ProviderAliasUtilities.getFullName(providerType);

    // Build a composite configuration from all matching sections
    final builder = ConfigurationBuilder();

    for (final logConfig in _configurations) {
      final config = logConfig.configuration;

      // Try to get configuration section using the alias first
      // (e.g., "Console")
      if (alias != null) {
        final aliasSection = config.getSection('Logging:$alias');
        if (_hasChildren(aliasSection)) {
          _addConfiguration(builder, aliasSection);
        }
      }

      // Also try the full type name (e.g., "ConsoleLoggerProvider")
      final fullNameSection = config.getSection('Logging:$fullName');
      if (_hasChildren(fullNameSection)) {
        _addConfiguration(builder, fullNameSection);
      }
    }

    return builder.build();
  }

  /// Checks if a configuration section has any children.
  bool _hasChildren(IConfiguration section) => section.getChildren().isNotEmpty;

  /// Adds all key-value pairs from a configuration section to the builder.
  void _addConfiguration(
    ConfigurationBuilder builder,
    IConfiguration section,
  ) {
    // Add all child key-value pairs from the section
    _addConfigurationValues(builder, section, prefix: '');
  }

  /// Recursively adds configuration values to the builder.
  void _addConfigurationValues(
    ConfigurationBuilder builder,
    IConfiguration section, {
    required String prefix,
  }) {
    final children = section.getChildren();

    for (final child in children) {
      final key = prefix.isEmpty ? child.key : '$prefix:${child.key}';
      final value = child.value;

      // If this child has a value, add it
      if (value != null) {
        // Create an in-memory source for this key-value pair
        builder.add(
          _InMemoryConfigurationSource({key: value}),
        );
      }

      // Recursively process children
      if (child.getChildren().isNotEmpty) {
        _addConfigurationValues(builder, child, prefix: key);
      }
    }
  }
}

/// Simple in-memory configuration source for building composite configurations.
class _InMemoryConfigurationSource implements ConfigurationSource {
  final Map<String, String?> _data;

  _InMemoryConfigurationSource(this._data);

  @override
  ConfigurationProvider build(ConfigurationBuilder builder) =>
      _InMemoryConfigurationProvider(_data);
}

/// Simple in-memory configuration provider.
class _InMemoryConfigurationProvider extends ConfigurationProvider
    with ConfigurationProviderMixin {
  _InMemoryConfigurationProvider(Map<String, String?> initialData) {
    data.addAll(initialData);
  }
}
