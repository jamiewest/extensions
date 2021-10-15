import 'configuration_builder.dart';
import 'configuration_provider.dart';
import 'configuration_source.dart';
import 'memory_configuration_provider.dart';

/// Represents in-memory data as an [ConfigurationSource].
class MemoryConfigurationSource implements ConfigurationSource {
  MemoryConfigurationSource([this.initialData]);

  /// The initial key value configuration pairs.
  Iterable<MapEntry<String, String?>>? initialData;

  /// Builds the [MemoryConfigurationProvider] for this source.
  @override
  ConfigurationProvider build(ConfigurationBuilder builder) =>
      MemoryConfigurationProvider(this);
}
