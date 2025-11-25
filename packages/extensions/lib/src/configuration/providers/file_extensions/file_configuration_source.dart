import 'package:path/path.dart' as p;

import '../../../file_providers/file_provider.dart';
import '../../../system/string.dart' as string;
import '../../configuration_builder.dart';
import '../../configuration_provider.dart';
import '../../configuration_source.dart';
import 'file_configuration_provider.dart' show FileConfigurationProvider;

/// Represents a base class for file based [ConfigurationSource].
abstract class FileConfigurationSource implements ConfigurationSource {
  /// Used to access the contents of the file.
  FileProvider? fileProvider;

  /// The path to the file.
  String? path;

  /// Determines if loading the file is optional.
  bool optional = false;

  /// Determines whether the source will be loaded if the underlying
  /// file changes.
  bool reloadOnChange = false;

  /// Number of milliseconds that reload will wait before calling load.
  /// This helps avoid triggering reload before a file is completely
  /// written. Default is 250.
  int reloadDelay = 250;

  /// Will be called if an uncaught exception occurs in
  /// [FileConfigurationProvider.load].
  // void Function(FileLoadExceptionContext context)? onLoadException;

  /// Builds the [ConfigurationProvider] for this source.
  @override
  ConfigurationProvider build(ConfigurationBuilder builder);

  /// Called to use any default settings on the builder like
  /// the [FileProvider] or [FileLoadExceptionHandler].
  void ensureDefaults(ConfigurationBuilder builder) {
    // if (fileProvider == null && builder.getUserDefinedFileProvider() == null) {
    //   _ownsFileProvider = true;
    // }

    // fileProvider ??= builder.getFileProvider();
    // onLoadException ??= builder.getFileLoadExceptionHandler();
  }

  /// If no file provider has been set, for absolute Path, this will creates
  /// a physical file provider for the nearest existing directory.
  void resolveFileProvider() {
    if (fileProvider == null &&
        !string.isNullOrEmpty(path) &&
        p.isRootRelative(path!)) {
      // TODO(jamiewest): Implement file provider resolution.
    }
  }
}
