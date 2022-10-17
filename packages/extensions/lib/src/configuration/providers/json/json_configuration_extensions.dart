import '../../configuration_builder.dart';
import 'json_configuration_provider.dart';
import 'json_configuration_source.dart';

/// Extension methods for adding [JsonConfigurationProvider].
extension JsonConfigurationExtensions on ConfigurationBuilder {
  ConfigurationBuilder addJson(String input) {
    add(JsonConfigurationSource(input));
    return this;
  }
}
