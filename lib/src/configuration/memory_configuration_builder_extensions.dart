import 'configuration_builder.dart';
import 'memory_configuration_source.dart';

/// ConfigurationBuilder extension methods for the MemoryConfigurationProvider.
extension MemoryConfigurationBuilderExtensions on ConfigurationBuilder {
  /// Adds the memory configuration provider to `configurationBuilder`.
  ConfigurationBuilder addInMemoryCollection(
      [Iterable<MapEntry<String, String>>? initialData]) {
    add(MemoryConfigurationSource(initialData ??= {}));
    return this;
  }
}
