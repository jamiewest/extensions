import 'chained_configuration_provider.dart';
import 'configuration.dart';
import 'configuration_builder.dart';
import 'configuration_provider.dart';
import 'configuration_source.dart';

/// Represents a chained [Configuration] as an [ConfigurationSource].
class ChainedConfigurationSource implements ConfigurationSource {
  /// The chained configuration.
  Configuration? configuration;

  /// Whether the chained configuration should be disposed when the
  /// configuration provider gets disposed.
  bool? shouldDisposeConfiguration;

  /// Builds the [ChainedConfigurationProvider] for this source.
  @override
  ConfigurationProvider build(ConfigurationBuilder builder) =>
      ChainedConfigurationProvider(this);
}
