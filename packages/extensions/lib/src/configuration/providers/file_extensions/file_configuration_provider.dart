import 'dart:io' as io;

import '../../../primitives/change_token.dart';
import '../../../system/disposable.dart';
import '../../configuration_provider.dart';
import 'file_configuration_source.dart';
import 'file_load_exception_context.dart';

/// Provides the base class for file-based [ConfigurationProvider] providers.
abstract class FileConfigurationProvider extends ConfigurationProvider
    with ConfigurationProviderMixin
    implements Disposable {
  final FileConfigurationSource _source;
  Disposable? _changeTokenRegistration;

  /// Initializes a new instance with the specified source.
  FileConfigurationProvider(FileConfigurationSource source) : _source = source {
    if (source.reloadOnChange && source.fileProvider != null) {
      _changeTokenRegistration = ChangeToken.onChange(
        () => source.fileProvider!.watch(source.path!),
        () {
          io.sleep(Duration(milliseconds: source.reloadDelay));
          _loadInternal(reload: true);
        },
      );
    }
  }

  /// Gets the source settings for this provider.
  FileConfigurationSource get source => _source;

  /// Generates a string representing this provider name and relevant details.
  @override
  String toString() => "$runtimeType for '${source.path}' "
      "(${source.optional ? 'Optional' : 'Required'})";

  /// Loads the contents of the file at [FileConfigurationSource.path].
  ///
  /// Throws [io.FileSystemException] if [FileConfigurationSource.optional] is
  /// false and a file does not exist at specified path.
  ///
  /// Throws [FormatException] if an exception was thrown by the concrete
  /// implementation of the [loadFromFile] method. Use the source
  /// [FileConfigurationSource.onLoadException] callback if you need more
  /// control over the exception.
  @override
  void load() => _loadInternal(reload: false);

  /// Loads this provider's data from a file path.
  ///
  /// The derived class must implement this method to read and parse the file
  /// contents and populate the [data] dictionary.
  void loadFromFile(String filePath);

  void _loadInternal({required bool reload}) {
    final file = source.fileProvider?.getFileInfo(source.path ?? '');

    if (file == null || !file.exists) {
      if (source.optional || reload) {
        // Always optional on reload
        data.clear();
      } else {
        final error = StringBuffer(
          "The configuration file '${source.path}' was not found "
          'and is not optional.',
        );
        if (file?.physicalPath != null && file!.physicalPath!.isNotEmpty) {
          error.write(
            " The expected physical path was '${file.physicalPath}'.",
          );
        }
        _handleException(
          io.FileSystemException(error.toString(), source.path),
        );
      }
    } else {
      try {
        if (file.physicalPath == null) {
          throw io.FileSystemException(
            'File does not have a physical path',
            source.path,
          );
        }
        loadFromFile(file.physicalPath!);
      } catch (ex) {
        if (reload) {
          data.clear();
        }
        final exception = FormatException(
          "Failed to load configuration from file '${file.physicalPath}': $ex",
        );
        _handleException(exception);
      }
    }

    onReload();
  }

  void _handleException(Exception exception) {
    var ignoreException = false;

    if (source.onLoadException != null) {
      final exceptionContext = FileLoadExceptionContext()
        ..provider = this
        ..exception = exception;

      source.onLoadException!(exceptionContext);
      ignoreException = exceptionContext.ignore;
    }

    if (!ignoreException) {
      throw exception;
    }
  }

  @override
  void dispose() => _dispose(true);

  /// Disposes the provider.
  ///
  /// [disposing] is true if invoked from [Disposable.dispose].
  void _dispose(bool disposing) {
    _changeTokenRegistration?.dispose();
  }
}
