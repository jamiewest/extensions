import '../../../../configuration.dart';
import 'json_stream_configuration_source.dart';

class JsonStreamConfigurationProvider extends StreamConfigurationProvider
    with ConfigurationProviderMixin {
  JsonStreamConfigurationProvider(JsonStreamConfigurationSource super.source);

  @override
  void loadStream(Stream<dynamic> stream) {}
}
