import 'dart:io' as io;

import '../../../file_providers/file_provider.dart';
import '../../../file_providers/providers/physical/physical_file_provider.dart';
import '../../configuration_builder.dart';
import 'file_load_exception_context.dart';

const String _fileProviderKey = 'FileProvider';
const String _fileLoadExceptionHandlerKey = 'FileLoadExceptionHandler';

/// Provides extension methods for file-based configuration providers.
extension FileConfigurationExtensions on ConfigurationBuilder {
  /// Sets the default [FileProvider] to be used for file-based providers.
  ///
  /// [fileProvider] - The default file provider instance.
  ///
  /// Returns the [ConfigurationBuilder].
  ConfigurationBuilder setFileProvider(FileProvider fileProvider) {
    properties[_fileProviderKey] = fileProvider;
    return this;
  }

  FileProvider? _getUserDefinedFileProvider() {
    if (properties.containsKey(_fileProviderKey)) {
      return properties[_fileProviderKey] as FileProvider?;
    }
    return null;
  }

  /// Gets the default [FileProvider] to be used for file-based providers.
  ///
  /// Returns the default [FileProvider].
  FileProvider getFileProvider() {
    final provider = _getUserDefinedFileProvider();
    if (provider != null) {
      return provider;
    }

    // Use current directory as default, similar to .NET's
    // AppContext.BaseDirectory
    return PhysicalFileProvider(io.Directory.current.path);
  }

  /// Sets the FileProvider for file-based providers to a PhysicalFileProvider
  /// with the base path.
  ///
  /// [basePath] - The absolute path of file-based providers.
  ///
  /// Returns the [ConfigurationBuilder].
  ConfigurationBuilder setBasePath(String basePath) =>
      setFileProvider(PhysicalFileProvider(basePath));

  /// Sets a default action to be invoked for file-based providers when
  /// an error occurs.
  ///
  /// [handler] - The Action to be invoked on a file load exception.
  ///
  /// Returns the [ConfigurationBuilder].
  ConfigurationBuilder setFileLoadExceptionHandler(
    void Function(FileLoadExceptionContext context) handler,
  ) {
    properties[_fileLoadExceptionHandlerKey] = handler;
    return this;
  }

  /// Gets a default action to be invoked for file-based providers when
  /// an error occurs.
  ///
  /// Returns the Action to be invoked on a file load exception, if set.
  void Function(FileLoadExceptionContext context)?
      getFileLoadExceptionHandler() {
    if (properties.containsKey(_fileLoadExceptionHandlerKey)) {
      return properties[_fileLoadExceptionHandlerKey] as void Function(
          FileLoadExceptionContext context)?;
    }
    return null;
  }
}
