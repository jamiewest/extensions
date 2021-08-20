/*
  Changed `public abstract void Load(Stream stream);` 
  to `void loadStream(Stream stream)`.
*/
import 'configuration_provider.dart';
import 'stream_configuration_source.dart';

/// Stream based configuration provider
abstract class StreamConfigurationProvider extends ConfigurationProvider {
  final StreamConfigurationSource _source;
  bool _loaded;

  /// Constructor.
  StreamConfigurationProvider(StreamConfigurationSource source)
      : _source = source,
        _loaded = false;

  /// Load the configuration data from the stream.
  void loadStream(Stream stream);

  /// Load the configuration data from the stream.
  /// Will throw after the first call.
  @override
  void load() {
    if (_loaded) {
      throw Exception(
        'StreamConfigurationProviders cannot be loaded more than once.',
      );
    }
    loadStream(
        _source.stream!); // TODO: Find better way to avoid late null check.
    _loaded = true;
  }
}
