import '../primitives/change_token.dart';

import 'configuration_section.dart';

/// Represents a set of key/value application configuration properties.
///
/// Ports the C# `IConfiguration` interface; the `I` prefix is dropped per
/// this repo's naming rules.
abstract class Configuration {
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

  /// Returns a [ChangeToken] that can be used to observe when
  /// this configuration is reloaded.
  ChangeToken getReloadToken();
}

/// Alias for [Configuration], kept for one release of migration room.
@Deprecated('Use Configuration instead. Removed in the release after 0.8.0.')
typedef IConfiguration = Configuration;
