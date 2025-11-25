import 'package:collection/collection.dart';
import 'configuration.dart';
import 'configuration_section.dart';

/// Extension methods for configuration classes.
extension ConfigurationExtensions on Configuration {
  /// Gets the connection string
  ///
  /// Shorthand for GetSection("ConnectionStrings")[name].
  String? getConnectionString(String name) =>
      getSection('ConnectionStrings')[name];

  /// Get the enumeration of key value pairs within the [Configuration]
  ///
  /// If the `makePathsRelative` is true, the child keys returned will have the
  /// current configuration's Path trimmed from the front.
  Iterable<MapEntry<String, String>> asIterable({
    bool makePathsRelative = false,
  }) sync* {
    var stack = QueueList<Configuration>()..addFirst(this);
    var rootSection =
        (this is ConfigurationSection) ? this as ConfigurationSection : null;
    var prefixLength = makePathsRelative && rootSection != null
        ? rootSection.path.length + 1
        : 0;

    while (stack.isNotEmpty) {
      var config = stack.removeFirst();
      if ((config is ConfigurationSection) &&
          (!makePathsRelative || (config != this))) {
        yield MapEntry<String, String>(
          config.path.substring(prefixLength),
          config.value ??= '',
          //config.value != null ? config.value as String : null,
        );
      }
      for (var child in config.getChildren()) {
        stack.addFirst(child);
      }
    }
  }

  /// Gets a configuration sub-section with the specified key.
  ///
  /// If no matching sub-section is found with the specified key,
  /// an exception is raised.
  IConfigurationSection getRequiredSection(String key) {
    var section = getSection(key);
    if (section is ConfigurationSection && section.exists()) {
      return section;
    }
    throw Exception('Section $key not found in configuration.');
  }
}

/// Extension methods for configuration section classes.
extension ConfigurationSectionExtensions on ConfigurationSection {
  /// Determines whether the section has a [ConfigurationSection]
  /// `value` or has children
  bool exists() => value != null || getChildren().isNotEmpty;
}
