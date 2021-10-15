import 'dart:collection';

import 'configuration_provider.dart';
import 'memory_configuration_source.dart';

/// In-memory implementation of [ConfigurationProvider]
class MemoryConfigurationProvider extends ConfigurationProvider
    with IterableMixin<MapEntry<String, String?>>, ConfigurationProviderMixin {
  final MemoryConfigurationSource _source;

  /// Initialize a new instance from the source.
  MemoryConfigurationProvider(MemoryConfigurationSource source)
      : _source = source {
    if (_source.initialData != null) {
      for (var pair in _source.initialData!) {
        data[pair.key] = pair.value;
      }
    }
  }

  /// Add a new key and value pair.
  void add(String key, String value) => data[key] = value;

  /// Returns an enumerator that iterates through the collection.
  @override
  Iterator<MapEntry<String, String?>> get iterator =>
      data.entries.map((e) => MapEntry(e.key, e.value)).toList().iterator;
}
