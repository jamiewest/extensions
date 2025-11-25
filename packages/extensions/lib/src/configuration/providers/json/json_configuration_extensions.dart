import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../file_providers/providers/physical/physical_file_provider.dart';
import '../../configuration_builder.dart';
import '../file_extensions/file_configuration_extensions.dart';
import 'json_configuration_provider.dart';
import 'json_configuration_source.dart';
import 'json_file_configuration_source.dart';

/// Extension methods for adding [JsonConfigurationProvider].
extension JsonConfigurationExtensions on ConfigurationBuilder {
  /// Adds a JSON configuration source from a string.
  ConfigurationBuilder addJson(
    String input, {
    bool optional = false,
    bool reloadOnChange = false,
  }) {
    // Check if input looks like a file path
    if (_isFilePath(input)) {
      return addJsonFile(
        input,
        optional: optional,
        reloadOnChange: reloadOnChange,
      );
    }

    // Otherwise treat as JSON content
    add(JsonConfigurationSource(input));
    return this;
  }

  /// Adds a JSON configuration source from a file.
  ConfigurationBuilder addJsonFile(
    String path, {
    bool optional = false,
    bool reloadOnChange = false,
  }) =>
      _addJsonFile(
        path: path,
        optional: optional,
        reloadOnChange: reloadOnChange,
      );

  ConfigurationBuilder _addJsonFile({
    required String path,
    required bool optional,
    required bool reloadOnChange,
  }) {
    var source = JsonFileConfigurationSource()
      ..path = path
      ..optional = optional
      ..reloadOnChange = reloadOnChange
      ..fileProvider = getFileProvider()
      ..resolveFileProvider();

    add(source);
    return this;
  }

  bool _isFilePath(String input) {
    // Check if it has a file extension
    if (input.endsWith('.json')) {
      return true;
    }

    // Check if it's a path (contains path separators)
    if (input.contains('/') || input.contains(r'\')) {
      return true;
    }

    // Check if the file exists
    try {
      var provider = getFileProvider();
      String basePath;

      if (provider is PhysicalFileProvider) {
        basePath = provider.root;
      } else {
        basePath = p.current;
      }

      var fullPath = p.join(basePath, input);
      return File(fullPath).existsSync() || File(input).existsSync();
    } catch (_) {
      return false;
    }
  }
}
