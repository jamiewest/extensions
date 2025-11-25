import 'chained_configuration_source.dart';
import 'configuration.dart';
import 'configuration_builder.dart';

/// Extension methods for adding [Configuration] to a [ConfigurationBuilder].
extension ChainedBuilderExtensions on ConfigurationBuilder {
  /// Adds an existing configuration to [ConfigurationBuilder].
  ConfigurationBuilder addConfiguration(
    Configuration config, [
    bool shouldDisposeConfiguration = false,
  ]) {
    add(
      ChainedConfigurationSource()
        ..configuration = config
        ..shouldDisposeConfiguration = shouldDisposeConfiguration,
    );
    return this;
  }
}
