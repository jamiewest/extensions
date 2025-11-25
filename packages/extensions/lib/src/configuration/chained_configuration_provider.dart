import '../primitives/change_token.dart';
import '../system/disposable.dart';
import '../system/exceptions/argument_exception.dart';
import 'chained_configuration_source.dart';
import 'configuration.dart';
import 'configuration_key_comparator.dart';
import 'configuration_provider.dart';

/// Chained implementation of [ConfigurationProvider].
class ChainedConfigurationProvider
    implements ConfigurationProvider, Disposable {
  late final Configuration _config;
  bool _shouldDisposeConfig;

  /// Initialize a new instance from the source configuration.
  ChainedConfigurationProvider(ChainedConfigurationSource source)
      : _shouldDisposeConfig = false {
    if (source.configuration == null) {
      throw ArgumentException(
        message: 'Null is not a valid value for \'source.configuration\'.',
      );
    }
    _config = source.configuration!;
    _shouldDisposeConfig = source.shouldDisposeConfiguration;
  }

  /// Gets the chained configuration.
  Configuration get configuration => _config;

  /// Tries to get a configuration value for the specified key.
  @override
  (bool, String?) tryGet(String key) {
    var value = _config[key];
    if (value != null) {
      return (true, value);
    }
    return (false, null);
  }

  /// Sets a configuration value for the specified key.
  @override
  void set(String key, String? value) => _config[key] = value;

  /// Returns a change token if this provider supports change
  /// tracking, null otherwise.
  @override
  IChangeToken getReloadToken() => _config.getReloadToken();

  /// Loads configuration values from the source represented
  /// by this [ConfigurationProvider].
  @override
  void load() {}

  /// Returns the immediate descendant configuration keys for a given
  /// parent path based on this [ConfigurationProvider]s data and the
  /// set of keys returned by all the preceding [ConfigurationProvider]s.
  @override
  Iterable<String> getChildKeys(
    Iterable<String> earlierKeys,
    String? parentPath,
  ) {
    var section = parentPath == null ? _config : _config.getSection(parentPath);
    var keys = <String>[];
    for (var child in section.getChildren()) {
      keys.add(child.key);
    }
    keys
      ..addAll(earlierKeys)
      ..sort(configurationKeyComparator);
    return keys;
  }

  @override
  void dispose() {
    if (_shouldDisposeConfig) {
      (_config as Disposable).dispose();
    }
  }
}
