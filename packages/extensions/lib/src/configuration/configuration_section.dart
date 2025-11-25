import '../primitives/change_token.dart';
import 'configuration.dart';
import 'configuration_path.dart';
import 'configuration_root.dart';
import 'internal_configuration_root_extensions.dart';

/// Represents a section of application configuration values.
///
/// Adapted from [`Microsoft.Extensions.Configuration.Abstractions`]()
abstract class IConfigurationSection implements IConfiguration {
  /// Gets the key this section occupies in its parent.
  String get key;

  /// Gets the full path to this section within the [IConfiguration].
  String get path;

  /// Gets or sets the section value.
  String? value;
}

/// Represents a section of application configuration values.
class ConfigurationSection implements IConfigurationSection {
  final ConfigurationRoot _root;
  final String _path;
  String? _key;

  /// Initializes a new instance.
  ConfigurationSection(
    ConfigurationRoot root,
    String path,
  )   : _root = root,
        _path = path;

  /// Gets the full path to this section from the [ConfigurationRoot].
  @override
  String get path => _path;

  /// Gets the key this section occupies in its parent.
  @override
  String get key => _key ??= ConfigurationPath.getSectionKey(_path) ?? '';

  /// Gets the section value.
  @override
  String? get value => _root[path];

  /// Sets the section value.
  @override
  set value(String? v) => _root[path] = v;

  /// Gets the value corresponding to a configuration key.
  @override
  String? operator [](String key) =>
      _root[ConfigurationPath.combine([path, key])];

  /// Sets the value corresponding to a configuration key.
  @override
  void operator []=(String key, String? value) {
    _root[ConfigurationPath.combine([path, key])] = value;
  }

  /// Gets a configuration sub-section with the specified key.
  @override
  ConfigurationSection getSection(String key) =>
      _root.getSection(ConfigurationPath.combine([path, key]));

  /// Gets the immediate descendant configuration sub-sections.
  @override
  Iterable<ConfigurationSection> getChildren() =>
      _root.getChildrenImplementation(path);

  /// Returns a [IChangeToken] that can be used to observe when
  /// this configuration is reloaded.
  @override
  IChangeToken getReloadToken() => _root.getReloadToken();
}
