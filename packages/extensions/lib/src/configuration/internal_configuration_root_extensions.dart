import 'configuration_path.dart';
import 'configuration_provider.dart';
import 'configuration_root.dart';
import 'configuration_section.dart';

/// Extensions method for [ConfigurationRoot].
extension InternalConfigurationRootExtensions on ConfigurationRoot {
  /// Gets the immediate children sub-sections of configuration root
  /// based on key.
  Iterable<ConfigurationSection> getChildrenImplementation(String? path) =>
      providers
          .fold<Iterable<String>>(
            const Iterable<String>.empty(),
            (Iterable<String> seed, ConfigurationProvider source) =>
                source.getChildKeys(seed, path),
          )
          .toSet()
          .map(
            (key) => getSection(
              path == null ? key : ConfigurationPath.combine([path, key]),
            ),
          );
}
