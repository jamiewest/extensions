import 'dart:io' show File;

import '../../../primitives/change_token.dart';
import '../../../system/disposable.dart';
import '../../configuration_provider.dart';
import 'file_configuration_source.dart';

/// Base class for file based [ConfigurationProvider].
abstract class FileConfigurationProvider extends ConfigurationProvider
    with ConfigurationProviderMixin
    implements Disposable {
  final FileConfigurationSource _source;

  /// Initializes a new instance with the specified source.
  FileConfigurationProvider(FileConfigurationSource source) : _source = source {
    if (source.reloadOnChange && source.fileProvider != null) {
      ChangeToken.onChange(() => null, () {});
    }
  }

  /// The source settings for this provider.
  FileConfigurationSource get source => _source;

  /// Generates a string representing this provider name and relevant details.
  @override
  String toString() => '$runtimeType(${source.path})';

  /// Loads the file contents as a string, or returns null if the file
  /// doesn't exist and optional is true.
  String? loadFile() {
    var file = source.fileProvider?.getFileInfo(source.path ?? '');

    if (file == null || !file.exists) {
      if (source.optional) {
        return null;
      }
      throw Exception(
        'The configuration file \'${source.path}\' was not found and is not'
        ' optional.',
      );
    }

    try {
      // Read the file using physicalPath if available
      if (file.physicalPath != null) {
        return File(file.physicalPath!).readAsStringSync();
      }

      throw Exception('File does not have a physical path');
    } catch (e) {
      if (source.optional && e.toString().contains('No such file')) {
        return null;
      }
      throw Exception(
        'Failed to load configuration from file \'${source.path}\': $e',
      );
    }
  }

  @override
  void dispose() {
    // Clean up any file watchers if needed
  }
}
