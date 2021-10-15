import '../../configuration_builder.dart';
import '../../configuration_provider.dart';
import '../../configuration_source.dart';
import 'environment_variables_configuration_provider.dart';

/// Represents environment variables as an [ConfigurationSource].
class EnvironmentVariablesConfigurationSource implements ConfigurationSource {
  EnvironmentVariablesConfigurationSource({this.prefix});

  /// A prefix used to filter environment variables.
  String? prefix;

  /// Builds the [EnvironmentVariablesConfigurationProvider] for this source.
  @override
  ConfigurationProvider build(ConfigurationBuilder builder) =>
      EnvironmentVariablesConfigurationProvider(prefix!);
}
