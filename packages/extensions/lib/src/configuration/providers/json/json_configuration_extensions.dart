import '../../configuration_builder.dart';
import 'json_configuration_source.dart';

extension JsonConfigurationExtensions on ConfigurationBuilder {
  ConfigurationBuilder addJson() {
    add(JsonConfigurationSource());
    return this;
  }
}
