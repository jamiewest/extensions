import 'configuration.dart';
import 'configuration_provider.dart';
import 'configuration_root.dart';
import 'configuration_source.dart';

/// Used to build key/value based configuration settings for use in an
/// application.
class ConfigurationBuilder {
  final List<ConfigurationSource> _sources = <ConfigurationSource>[];

  /// Gets the sources used to obtain configuration values.
  List<ConfigurationSource> get sources => _sources;

  /// Gets a key/value collection that can be used to share data between
  /// the [ConfigurationBuilder] and the registered [ConfigurationSource]s.
  Map<String, Object> get properties => <String, Object>{};

  /// Adds a new configuration source.
  void add(ConfigurationSource source) {
    sources.add(source);
  }

  /// Builds a [Configuration] with keys and values from the set of
  /// sources registered in [sources].
  ConfigurationRoot build() {
    var providers = <ConfigurationProvider>[];
    for (var source in sources) {
      var provider = source.build(this);
      providers.add(provider);
    }
    return ConfigurationRoot(providers);
  }
}
