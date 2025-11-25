import '../../../file_providers/file_provider.dart';
import '../../../file_providers/providers/physical/physical_file_provider.dart';
import '../../configuration_builder.dart';
import 'file_configuration_provider.dart';
import 'file_load_exception_context.dart';

const String _fileProviderKey = 'FileProvider';
const String _fileLoadExceptionHandlerKey = 'FileLoadExceptionHandler';

/// Extension methods for [FileConfigurationProvider].
extension FileConfigurationExtensions on ConfigurationBuilder {
  /// Sets the default [FileProvider] to be used for file-based providers.
  ConfigurationBuilder setFileProvider(FileProvider fileProvider) {
    properties[_fileProviderKey] = fileProvider;
    return this;
  }

  FileProvider? _getUserDefinedFileProvider() {
    if (properties.containsKey(_fileProviderKey)) {
      return properties[_fileProviderKey] as FileProvider;
    }

    return null;
  }

  /// Gets the default [FileProvider] to be used for file-based providers.
  FileProvider getFileProvider() =>
      _getUserDefinedFileProvider() ?? PhysicalFileProvider('');

  /// Sets the FileProvider for file-based providers to a PhysicalFileProvider
  /// with the base path.
  ConfigurationBuilder setBasePath(String basepath) =>
      setFileProvider(PhysicalFileProvider(basepath));

  /// Sets a default action to be invoked for file-based providers when
  /// an error occurs.
  ConfigurationBuilder setFileLoadExceptionHandler(
      void Function(FileLoadExceptionContext context) handler) {
    properties[_fileLoadExceptionHandlerKey] = handler;
    return this;
  }

  /// Gets a default action to be invoked for file-based providers when
  /// an error occurs.
  void Function(FileLoadExceptionContext context)?
      getFileLoadExceptionHandler() {
    if (properties.containsKey(_fileLoadExceptionHandlerKey)) {
      return properties[_fileLoadExceptionHandlerKey] as void Function(
          FileLoadExceptionContext context);
    }
    return null;
  }
}
