import '../primitives/change_token.dart';

import 'configuration_section.dart';

/// Represents a set of key/value application configuration properties.
abstract class IConfiguration {
  /// Gets a configuration value.
  String? operator [](String key);

  /// Sets a configuration value;
  void operator []=(String key, String? value);

  /// Gets a configuration sub-section with the specified key.
  ///
  /// This method will never return `null`. If no matching sub-section
  /// is found with the specified key, an empty [ConfigurationSection]
  /// will be returned.
  IConfigurationSection getSection(String key);

  /// Returns the configuration sub-sections.
  ///
  /// Gets the immediate descendant configuration sub-sections.
  Iterable<IConfigurationSection> getChildren();

  /// Returns a [IChangeToken] that can be used to observe when
  /// this configuration is reloaded.
  IChangeToken getReloadToken();
}

/// Alias for [IConfiguration] for backwards compatibility.
typedef Configuration = IConfiguration;
