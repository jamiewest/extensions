import 'dart:collection';

import '../file_extensions/file_configuration_provider.dart';
import 'json_configuration_parser.dart';
import 'json_file_configuration_source.dart';

/// A JSON file based [FileConfigurationProvider].
class JsonFileConfigurationProvider extends FileConfigurationProvider {
  /// Creates a new [JsonFileConfigurationProvider].
  JsonFileConfigurationProvider(super.source);

  /// Loads the JSON data from the file.
  @override
  void load() {
    var fileData = loadFile();
    if (fileData != null) {
      try {
        data = LinkedHashMap.from(
          JsonConfigurationParser.parse(fileData),
        );
      } catch (e) {
        // If there's an error parsing the JSON, treat it as empty
        data = LinkedHashMap<String, String?>();
        rethrow;
      }
    } else {
      data = LinkedHashMap<String, String?>();
    }
  }
}
