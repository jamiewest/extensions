// import 'dart:io';

// import 'package:path/path.dart' as p;

// import '../../../file_providers/file_provider.dart';
// import '../../../file_providers/providers/physical/physical_file_provider.dart';
// import '../../../shared/string_utils.dart';
// import '../../configuration_builder.dart';
// import '../../configuration_provider.dart';
// import '../../configuration_source.dart';
// import 'file_configuration_extensions.dart';
// import 'file_load_exception_context.dart';

// typedef OnLoadException = void Function(FileLoadExceptionContext context);

// abstract class FileConfigurationSource implements IConfigurationSource {
//   /// Used to access the contents of the file.
//   IFileProvider? fileProvider;

//   /// The path to the file.
//   String? path;

//   /// Determines if loading the file is optional.
//   bool optional = false;

//   /// Determines whether the source will be loaded if the underlying
//   /// file changes.
//   bool reloadOnChange = false;

//   /// Number of milliseconds that reload will wait before calling Load.
//   /// This helps avoid triggering reload before a file is completely
//   /// written. Default is 250.
//   Duration reloadDelay = const Duration(milliseconds: 250);

//   /// Will be called if an uncaught exception occurs in
//   /// `FileConfigurationProvider.Load`.
//   OnLoadException? onLoadException;

//   /// Builds the [ConfigurationProvider] for this source.
//   @override
//   IConfigurationProvider build(IConfigurationBuilder builder);

//   /// Called to use any default settings on the builder like the
//   /// FileProvider or FileLoadExceptionHandler.
//   void ensureDefaults(IConfigurationBuilder builder) {
//     fileProvider = fileProvider ?? builder.getFileProvider();
//     onLoadException = onLoadException ?? builder.getFileLoadExceptionHandler();
//   }

//   /// If no file provider has been set, for absolute Path, this will
//   /// creates a physical file provider for the nearest existing directory.
//   void resolveFileProvider() {
//     if (fileProvider == null && !isNullOrEmpty(path) && p.isRelative(path!)) {
//       var directory = p.dirname(path!);
//       var pathToFile = p.basename(path!);

//       while (!isNullOrEmpty(directory) && !Directory(directory).existsSync()) {
//         pathToFile = p.join(p.basename(directory), pathToFile);
//         directory = p.dirname(directory);
//       }

//       if (Directory(directory).existsSync()) {
//         fileProvider = PhysicalFileProvider(directory);
//         path = pathToFile;
//       }
//     }
//   }
// }
