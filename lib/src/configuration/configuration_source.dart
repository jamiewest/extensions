import 'configuration_builder.dart';
import 'configuration_provider.dart';

/// Represents a source of configuration key/values for an application.
abstract class ConfigurationSource {
  /// Builds the [ConfigurationProvider] for this source.
  ConfigurationProvider build(ConfigurationBuilder builder);
}
