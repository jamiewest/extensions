import '../../configuration_builder.dart';
import '../../configuration_provider.dart';
import '../../configuration_source.dart';
import '../../stream_configuration_source.dart';
import 'json_stream_configuration_provider.dart';

/// Represents a JSON file as an [ConfigurationSource].
class JsonStreamConfigurationSource extends StreamConfigurationSource {
  /// Builds the [JsonStreamConfigurationProvider] for this source.
  @override
  ConfigurationProvider build(ConfigurationBuilder builder) =>
      JsonStreamConfigurationProvider(this);
}
