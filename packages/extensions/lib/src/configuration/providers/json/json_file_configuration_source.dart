import '../../../../configuration.dart' show ConfigurationSource;
import '../../../../configuration_io.dart' show ConfigurationSource;
import '../../../../io.dart' show ConfigurationSource;
import '../../configuration_builder.dart';
import '../../configuration_provider.dart';
import '../../configuration_source.dart' show ConfigurationSource;
import '../file_extensions/file_configuration_source.dart';
import 'json_file_configuration_provider.dart';

/// Represents a JSON file as a [ConfigurationSource].
class JsonFileConfigurationSource extends FileConfigurationSource {
  @override
  ConfigurationProvider build(ConfigurationBuilder builder) {
    ensureDefaults(builder);
    return JsonFileConfigurationProvider(this);
  }
}
