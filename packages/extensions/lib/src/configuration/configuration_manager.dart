import 'dart:collection';

import '../primitives/change_token.dart';
import 'configuration_builder.dart';
import 'configuration_provider.dart';
import 'configuration_root.dart';
import 'configuration_section.dart';
import 'configuration_source.dart';

class ConfigurationManager implements ConfigurationBuilder, ConfigurationRoot {
  ConfigurationManager() {}

  @override
  String? operator [](String key) {
    // TODO: implement []
    throw UnimplementedError();
  }

  @override
  void operator []=(String key, value) {
    // TODO: implement []=
  }

  @override
  ConfigurationBuilder add(ConfigurationSource source) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  ConfigurationRoot build() {
    // TODO: implement build
    throw UnimplementedError();
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  Iterable<ConfigurationSection> getChildren() {
    // TODO: implement getChildren
    throw UnimplementedError();
  }

  @override
  ChangeToken getReloadToken() {
    // TODO: implement getReloadToken
    throw UnimplementedError();
  }

  @override
  ConfigurationSection getSection(String key) {
    // TODO: implement getSection
    throw UnimplementedError();
  }

  @override
  // TODO: implement properties
  Map<String, dynamic> get properties => throw UnimplementedError();

  @override
  // TODO: implement providers
  Iterable<ConfigurationProvider> get providers => throw UnimplementedError();

  @override
  void reload() {
    // TODO: implement reload
  }

  @override
  // TODO: implement sources
  List<ConfigurationSource> get sources => throw UnimplementedError();
}

class _ConfigurationSources with ListMixin<ConfigurationSource> {
  final List<ConfigurationSource> _sources = <ConfigurationSource>[];
  final ConfigurationManager _config;

  _ConfigurationSources(ConfigurationManager config) : _config = config;

  @override
  ConfigurationSource operator [](int index) {
    throw UnimplementedError();
  }

  @override
  void operator []=(int index, ConfigurationSource value) {}

  @override
  int get length => _sources.length;

  @override
  set length(int value) => _sources.length = value;
}
