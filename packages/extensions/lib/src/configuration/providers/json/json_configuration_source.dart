import '../../configuration_builder.dart';
import '../../configuration_provider.dart';
import '../../configuration_source.dart';
import 'json_configuration_provider.dart';

class JsonConfigurationSource implements ConfigurationSource {
  JsonConfigurationSource(this.input);

  final String input;

  @override
  ConfigurationProvider build(ConfigurationBuilder builder) =>
      JsonConfigurationProvider(input);
}
