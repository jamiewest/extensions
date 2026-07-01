import 'dart:collection';

import '../../../file_providers/file_info.dart';
import '../../../file_providers/providers/physical/physical_file_info.dart';
import '../file_extensions/file_configuration_provider.dart';
import '../file_extensions/file_system_exception.dart';
import 'json_configuration_parser.dart';

/// A JSON file based [FileConfigurationProvider].
class JsonFileConfigurationProvider extends FileConfigurationProvider {
  /// Creates a new [JsonFileConfigurationProvider].
  JsonFileConfigurationProvider(super.source);

  /// Loads this provider's data from a [FileInfo].
  @override
  void loadFromFile(FileInfo file) {
    if (file is! PhysicalFileInfo) {
      throw FileSystemException(
        'JSON file configuration requires a PhysicalFileProvider-backed file.',
        file.physicalPath,
      );
    }

    try {
      final fileData = file.readAsStringSync();
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
