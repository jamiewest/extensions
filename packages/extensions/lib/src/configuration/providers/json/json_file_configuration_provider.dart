import 'dart:collection';
import 'dart:io';

import '../file_extensions/file_configuration_provider.dart';
import 'json_configuration_parser.dart';

/// A JSON file based [FileConfigurationProvider].
class JsonFileConfigurationProvider extends FileConfigurationProvider {
  /// Creates a new [JsonFileConfigurationProvider].
  JsonFileConfigurationProvider(super.source);

  /// Loads this provider's data from a file path.
  @override
  void loadFromFile(String filePath) {
    try {
      final fileData = File(filePath).readAsStringSync();
      data = LinkedHashMap.from(
        JsonConfigurationParser.parse(fileData),
      );
    } catch (e) {
      // If there's an error parsing the JSON, treat it as empty
      data = LinkedHashMap<String, String?>();
      rethrow;
    }
  }
}
