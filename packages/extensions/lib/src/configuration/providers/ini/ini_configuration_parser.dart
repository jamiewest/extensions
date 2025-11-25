import 'dart:collection';

import '../../configuration_path.dart';

/// Parses INI configuration data into key-value pairs.
class IniConfigurationParser {
  IniConfigurationParser._();

  /// Parses INI content from the input string and returns a dictionary of
  /// configuration key-value pairs.
  ///
  /// The method processes each line of the input:
  /// - Skips blank lines and comments (starting with `;`, `#`, or `/`)
  /// - Processes section headers in bracket notation `[Section]`
  /// - Parses key-value pairs with `=` delimiter
  /// - Builds hierarchical keys using the configured path delimiter
  ///
  /// Throws [FormatException] if:
  /// - A duplicate key is encountered
  /// - An empty section name is found
  /// - Invalid INI syntax is found
  static Map<String, String?> parse(String input) {
    final data = LinkedHashMap<String, String?>(
      equals: (a, b) => a.toLowerCase() == b.toLowerCase(),
      hashCode: (k) => k.toLowerCase().hashCode,
    );

    final lines = input.split('\n');
    String? currentSection;

    for (var lineNumber = 0; lineNumber < lines.length; lineNumber++) {
      final line = lines[lineNumber].trim();

      // Skip blank lines and comments
      if (line.isEmpty ||
          line.startsWith(';') ||
          line.startsWith('#') ||
          line.startsWith('/')) {
        continue;
      }

      // Handle section headers: [Section]
      if (line.startsWith('[') && line.endsWith(']')) {
        currentSection = line.substring(1, line.length - 1).trim();
        if (currentSection.isEmpty) {
          throw FormatException(
            'Empty section name at line ${lineNumber + 1}',
          );
        }
        continue;
      }

      // Parse key-value pairs
      final separatorIndex = line.indexOf('=');
      if (separatorIndex == -1) {
        throw FormatException(
          'Invalid INI syntax at line ${lineNumber + 1}: '
          "missing '=' separator",
        );
      }

      var key = line.substring(0, separatorIndex).trim();
      var value = line.substring(separatorIndex + 1).trim();

      // Remove quotes from value if present
      if (value.length >= 2 &&
          ((value.startsWith('"') && value.endsWith('"')) ||
              (value.startsWith("'") && value.endsWith("'")))) {
        value = value.substring(1, value.length - 1);
      }

      if (key.isEmpty) {
        throw FormatException(
          'Empty key at line ${lineNumber + 1}',
        );
      }

      // Build hierarchical key with section prefix
      final configKey = currentSection != null
          ? ConfigurationPath.combine([currentSection, key])
          : key;

      // Check for duplicate keys
      if (data.containsKey(configKey)) {
        throw FormatException(
          "Duplicate key '$configKey' at line ${lineNumber + 1}",
        );
      }

      data[configKey] = value;
    }

    return data;
  }
}
