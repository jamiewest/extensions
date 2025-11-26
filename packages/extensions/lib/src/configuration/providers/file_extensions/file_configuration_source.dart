import 'dart:io' as io;

import 'package:path/path.dart' as p;

import '../../../file_providers/file_provider.dart';
import '../../../file_providers/providers/physical/physical_file_provider.dart';
import '../../configuration_builder.dart';
import '../../configuration_provider.dart';
import '../../configuration_source.dart';
import 'file_configuration_extensions.dart';
import 'file_configuration_provider.dart' show FileConfigurationProvider;
import 'file_load_exception_context.dart';

/// Represents a base class for file based [ConfigurationSource].
abstract class FileConfigurationSource implements ConfigurationSource {
  /// Gets or sets the provider used to access the contents of the file.
  FileProvider? fileProvider;

  /// Gets or sets the path to the file.
  String? path;

  /// Gets or sets a value that indicates whether loading the file is optional.
  bool optional = false;

  /// Gets or sets a value that indicates whether the source will be loaded
  /// if the underlying file changes.
  bool reloadOnChange = false;

  /// Gets or sets the number of milliseconds that reload will wait before
  /// calling Load.
  ///
  /// The number of milliseconds that reload waits before calling Load.
  /// The default is 250.
  ///
  /// This delay helps avoid triggering reload before a file is completely
  /// written.
  int reloadDelay = 250;

  /// Gets or sets the action that's called if an uncaught exception occurs
  /// in [FileConfigurationProvider.load].
  void Function(FileLoadExceptionContext context)? onLoadException;

  /// Builds the [ConfigurationProvider] for this source.
  @override
  ConfigurationProvider build(ConfigurationBuilder builder);

  /// Called to use any default settings on the builder like the FileProvider
  /// or FileLoadExceptionHandler.
  void ensureDefaults(ConfigurationBuilder builder) {
    fileProvider ??= builder.getFileProvider();
    onLoadException ??= builder.getFileLoadExceptionHandler();
  }

  /// Creates a physical file provider for the nearest existing directory
  /// if no file provider has been set, for absolute Path.
  void resolveFileProvider() {
    if (fileProvider == null &&
        path != null &&
        path!.isNotEmpty &&
        p.isAbsolute(path!)) {
      String? directory = p.dirname(path!);
      String? pathToFile = p.basename(path!);

      while (directory != null &&
          directory.isNotEmpty &&
          !io.Directory(directory).existsSync()) {
        pathToFile = p.join(p.basename(directory), pathToFile);
        directory = p.dirname(directory);
      }

      if (directory != null &&
          directory.isNotEmpty &&
          io.Directory(directory).existsSync()) {
        fileProvider = PhysicalFileProvider(directory);
        path = pathToFile;
      }
    }
  }
}
