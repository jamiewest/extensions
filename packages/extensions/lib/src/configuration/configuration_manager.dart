import 'dart:collection';

import '../primitives/change_token.dart';
import '../system/disposable.dart';
import 'configuration_builder.dart';
import 'configuration_provider.dart';
import 'configuration_reload_token.dart';
import 'configuration_root.dart';
import 'configuration_section.dart';
import 'configuration_source.dart';
import 'internal_configuration_root_extensions.dart';
import 'memory_configuration_source.dart';

/// ConfigurationManager is a mutable configuration object. It is both an
/// [ConfigurationBuilder] and an [ConfigurationRoot]. As sources are added, it
/// updates its current view of configuration.
class ConfigurationManager
    implements ConfigurationBuilder, ConfigurationRoot, Disposable {
  late final ConfigurationSources _sources;
  late final ConfigurationBuilderProperties _properties;
  final List<Disposable> _changeTokenRegistrations = <Disposable>[];
  ConfigurationReloadToken _changeToken = ConfigurationReloadToken();
  final List<ConfigurationProvider> _providers = <ConfigurationProvider>[];

  /// Creates an empty mutable configuration object that is both an
  /// [ConfigurationBuilder] and an [ConfigurationRoot].
  ConfigurationManager() {
    _sources = ConfigurationSources(this);
    _properties = ConfigurationBuilderProperties(this);

    // Make sure there's some default storage since there are no default
    // providers.
    _sources.add(MemoryConfigurationSource());
  }

  @override
  String? operator [](String key) =>
      ConfigurationRoot.getConfiguration(_providers, key);

  @override
  void operator []=(String key, String? value) =>
      ConfigurationRoot.setConfiguration(_providers, key, value);

  @override
  ConfigurationSection getSection(String key) =>
      ConfigurationSection(this, key);

  @override
  Iterable<ConfigurationSection> getChildren() =>
      getChildrenImplementation(null);

  @override
  Map<String, Object> get properties => _properties;

  @override
  List<ConfigurationSource> get sources => _sources;

  @override
  void dispose() {
    _disposingRegistrations();
  }

  @override
  ConfigurationBuilder add(ConfigurationSource source) {
    _sources.add(source);
    return this;
  }

  @override
  ConfigurationRoot build() => this;

  @override
  IChangeToken getReloadToken() => _changeToken;

  @override
  void reload() {
    for (final provider in _providers) {
      provider.load();
    }

    _raiseChanged();
  }

  void _raiseChanged() {
    final previousToken = _changeToken;
    _changeToken = ConfigurationReloadToken();
    previousToken.onReload();
  }

  void _addSource(ConfigurationSource source) {
    final provider = source.build(this)..load();

    _changeTokenRegistrations.add(
      ChangeToken.onChange(provider.getReloadToken, _raiseChanged),
    );

    _providers.add(provider);
    _raiseChanged();
  }

  void _reloadSources() {
    _changeTokenRegistrations.clear();

    final newProvidersList = <ConfigurationProvider>[];

    for (final source in _sources) {
      newProvidersList.add(source.build(this));
    }

    for (final p in newProvidersList) {
      p.load();
      _changeTokenRegistrations.add(
        ChangeToken.onChange(p.getReloadToken, _raiseChanged),
      );
    }

    _providers
      ..clear()
      ..addAll(newProvidersList);
    _raiseChanged();
  }

  void _disposingRegistrations() {
    for (final registration in _changeTokenRegistrations) {
      registration.dispose();
    }
  }

  @override
  Iterable<ConfigurationProvider> get providers => _providers;
}

class ConfigurationSources with ListMixin<ConfigurationSource> {
  final List<ConfigurationSource> _sources = <ConfigurationSource>[];
  final ConfigurationManager _config;

  ConfigurationSources(ConfigurationManager config) : _config = config;

  @override
  int get length => _sources.length;

  @override
  set length(int value) => _sources.length = value;

  @override
  ConfigurationSource operator [](int index) => _sources[index];

  @override
  void operator []=(int index, ConfigurationSource value) =>
      _sources[index] = value;

  @override
  void add(ConfigurationSource element) {
    _sources.add(element);
    _config._addSource(element);
  }

  @override
  void clear() {
    super.clear();
    _config._reloadSources();
  }

  @override
  void insert(int index, ConfigurationSource element) {
    super.insert(index, element);
    _config._reloadSources();
  }

  @override
  bool remove(Object? element) {
    final removed = _sources.remove(element);
    _config._reloadSources();
    return removed;
  }

  @override
  ConfigurationSource removeAt(int index) {
    final removed = _sources.removeAt(index);
    _config._reloadSources();
    return removed;
  }
}

class ConfigurationBuilderProperties with MapMixin<String, Object> {
  final Map<String, Object> _properties = <String, Object>{};
  final ConfigurationManager _config;

  ConfigurationBuilderProperties(ConfigurationManager config)
      : _config = config;

  @override
  Object? operator [](Object? key) => _properties[key];

  @override
  void operator []=(String key, Object value) => _properties[key] = value;

  @override
  void clear() {
    _properties.clear();
    _config._reloadSources();
  }

  @override
  Iterable<String> get keys => _properties.keys;

  @override
  Object? remove(Object? key) {
    final removed = _properties.remove(key);
    _config._reloadSources();
    return removed;
  }
}
