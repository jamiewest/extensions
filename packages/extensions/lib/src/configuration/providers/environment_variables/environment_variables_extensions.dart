import '../../configuration_builder.dart';
import 'environment_variables_configuration_source.dart';

extension EnvironmentVariablesExtensions on ConfigurationBuilder {
  ConfigurationBuilder addEnvironmentVariables({String? prefix}) {
    add(EnvironmentVariablesConfigurationSource(prefix: prefix));
    return this;
  }
}
