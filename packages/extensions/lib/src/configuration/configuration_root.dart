import '../primitives/change_token.dart';
import '../shared/disposable.dart';
import 'configuration.dart';
import 'configuration_provider.dart';
import 'configuration_reload_token.dart';
import 'configuration_section.dart';
import 'internal_configuration_root_extensions.dart';

/// Represents the root of an [Configuration] hierarchy.
// abstract class ConfigurationRoot implements IConfiguration {
//   /// Force the configuration values to be reloaded from the underlying
//   /// [IConfigurationProvider]s.
//   void reload();

//   /// The [ConfigurationProvider]s for this configuration.
//   Iterable<ConfigurationProvider> get providers;
// }

/// Represents the root of an [Configuration] hierarchy.
class ConfigurationRoot implements Configuration, Disposable {
  final List<ConfigurationProvider> _providers;
  List<Disposable>? _changeTokenRegistrations;
  ConfigurationReloadToken _changeToken = ConfigurationReloadToken();

  /// Initializes a Configuration root with a list of providers.
  ConfigurationRoot(List<ConfigurationProvider> providers)
      : _providers = providers {
    _changeTokenRegistrations = <Disposable>[];
    for (var provider in providers) {
      provider.load();
      _changeTokenRegistrations?.add(
          ChangeToken.onChange(() => provider.getReloadToken(), _raiseChanged));
    }
  }

  /// The [ConfigurationProvider]s for this configuration.
  Iterable<ConfigurationProvider> get providers => _providers;

  /// Gets the value corresponding to a configuration key.
  @override
  String? operator [](String key) {
    for (var i = _providers.length - 1; i >= 0; i--) {
      var provider = _providers[i];
      var result = provider.tryGet(key);
      if (result[0] == true) {
        return result[1] == null ? null : result[1] as String;
      }
    }
    return null;
  }

  /// Sets the value corresponding to a configuration key.
  @override
  void operator []=(String key, dynamic value) {
    if (_providers.isEmpty) {
      throw Exception('SR.Error_NoSources');
    }
    for (var provider in _providers) {
      provider.set(key, value as String);
    }
  }

  /// Gets the immediate children sub-sections.
  @override
  Iterable<ConfigurationSection> getChildren() =>
      getChildrenImplementation(null);

  /// Returns a [ChangeToken] that can be used to observe
  /// when this configuration is reloaded.
  @override
  ChangeToken getReloadToken() => _changeToken;

  /// Gets a configuration sub-section with the specified key.
  @override
  ConfigurationSection getSection(String key) =>
      ConfigurationSection(this, key);

  /// Force the configuration values to be reloaded from the
  /// underlying [ConfigurationProvider]s.
  void reload() {
    for (var provider in _providers) {
      provider.load();
    }
    _raiseChanged();
  }

  void _raiseChanged() {
    var previousToken = _changeToken;
    _changeToken = ConfigurationReloadToken();
    previousToken.onReload();
  }

  @override
  void dispose() {
    // dispose change token registrations
    for (var registration in _changeTokenRegistrations!) {
      registration.dispose();
    }

    // dispose providers
    for (var provider in _providers) {
      if (provider is Disposable) {
        (provider as Disposable).dispose();
      }
    }
  }
}
