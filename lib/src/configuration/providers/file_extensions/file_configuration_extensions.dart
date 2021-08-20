// import '../../../../configuration.dart';
// import '../../../file_providers/file_provider.dart';
// import '../../../file_providers/providers/physical/physical_file_provider.dart';
// import 'file_configuration_source.dart';

// extension FileConfigurationExtensions on ConfigurationBuilder {
//   static const String _fileProviderKey = 'FileProvider';
//   static const String _fileLoadExceptionHandlerKey = 'FileLoadExceptionHandler';

//   /// Sets the default [IFileProvider] to used for file-based providers.
//   ConfigurationBuilder setFileProvider(IFileProvider fileProvider) {
//     properties[_fileProviderKey] = fileProvider;
//     return this;
//   }

//   /// Gets the default [IFileProvider] to used for file-based providers
//   IFileProvider getFileProvider() => PhysicalFileProvider('');

//   /// Sets the FileProvider for file-based providers to a
//   /// [PhysicalFileProvider] with the base path.
//   IConfigurationBuilder setBasePath(String basePath) =>
//       setFileProvider(PhysicalFileProvider(basePath));

//   /// Sets a default action to be invoked for file-based providers when an
//   /// error occurs.
//   IConfigurationBuilder setFileLoadExceptionHandler(OnLoadException handler) {
//     properties[_fileLoadExceptionHandlerKey] = handler;
//     return this;
//   }

//   /// Gets the default [IFileProvider] to used for file-based providers.
//   OnLoadException? getFileLoadExceptionHandler() {
//     if (properties.containsKey(_fileLoadExceptionHandlerKey)) {
//       return properties[_fileLoadExceptionHandlerKey] as OnLoadException;
//     }
//     return null;
//   }
// }
