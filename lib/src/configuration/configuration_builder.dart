import 'configuration_provider.dart';
import 'configuration_root.dart';
import 'configuration_source.dart';

/// Represents a type used to build application configuration.
// abstract class ConfigurationBuilder {
//   /// Gets a key/value collection that can be used to share data between the [ConfigurationBuilder]
//   /// and the registered [ConfigurationSource]s.
//   Map<String, dynamic> get properties;

//   /// Gets the sources used to obtain configuration values
//   List<ConfigurationSource> get sources;

//   /// Adds a new configuration source.
//   IConfigurationBuilder add(ConfigurationSource source);

//   /// Builds a `IConfiguration` with keys and values from the set of
//   /// sources registered in Sources.
//   IConfigurationRoot build();
// }

/// Represents a type used to build application configuration.
class ConfigurationBuilder {
  final List<ConfigurationSource> _sources = <ConfigurationSource>[];

  /// Gets a key/value collection that can be used to share data between
  /// the [ConfigurationBuilder] and the registered [ConfigurationSource]s.
  @override
  Map<String, dynamic> get properties => <String, dynamic>{};

  /// Gets the sources used to obtain configuration values.
  @override
  List<ConfigurationSource> get sources => _sources;

  /// Adds a new configuration source.
  // ignore: avoid_returning_this
  @override
  ConfigurationBuilder add(ConfigurationSource source) {
    try {
      sources.add(source);
    } catch (e) {
      // TODO: Catch exception.
      print(e.toString);
    }

    return this;
  }

  /// Builds a `IConfiguration` with keys and values from the set of
  /// sources registered in Sources.
  @override
  ConfigurationRoot build() {
    var providers = <ConfigurationProvider>[];
    for (var source in sources) {
      var provider = source.build(this);
      providers.add(provider);
    }
    return ConfigurationRoot(providers);
  }
}
