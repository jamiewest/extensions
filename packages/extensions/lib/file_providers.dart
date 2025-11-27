/// Provides abstractions for file system operations with change tracking
/// and composite file providers.
///
/// This library implements file provider abstractions inspired by
/// Microsoft.Extensions.FileProviders, enabling unified access to files
/// from various sources (physical disk, embedded resources, etc.) with
/// change notification support.
///
/// ## Physical File Provider
///
/// Access files from the physical file system:
///
/// ```dart
/// final provider = PhysicalFileProvider('/path/to/files');
///
/// final fileInfo = provider.getFileInfo('config.json');
/// if (fileInfo.exists) {
///   final contents = await fileInfo.readAsString();
/// }
/// ```
///
/// ## Watch for Changes
///
/// React to file system changes:
///
/// ```dart
/// final changeToken = provider.watch('**/*.json');
/// changeToken.registerChangeCallback(() {
///   print('JSON files changed!');
/// });
/// ```
///
/// ## Composite File Provider
///
/// Combine multiple file providers:
///
/// ```dart
/// final composite = CompositeFileProvider([
///   PhysicalFileProvider('/app/files'),
///   PhysicalFileProvider('/shared/files'),
/// ]);
///
/// // Searches all providers for the file
/// final file = composite.getFileInfo('config.json');
/// ```
///
/// ## Directory Enumeration
///
/// List directory contents:
///
/// ```dart
/// final contents = provider.getDirectoryContents('/configs');
/// for (final item in contents) {
///   print('${item.name} - ${item.isDirectory}');
/// }
/// ```
library;

export 'package:cross_file/cross_file.dart';
export 'package:file/file.dart';

// Microsoft.Extensions.FileProviders.Abstractions
export '../src/file_providers/directory_contents.dart';
export '../src/file_providers/file_info.dart';
export '../src/file_providers/file_not_found_exception.dart';
export '../src/file_providers/file_provider.dart';
export '../src/file_providers/not_found_directory_contents.dart';
export '../src/file_providers/not_found_file_info.dart';
export '../src/file_providers/null_change_token.dart';
export '../src/file_providers/null_file_provider.dart';

// Microsoft.Extensions.FileProviders.Composite
export '../src/file_providers/providers/composite/composite_file_provider.dart';

// Microsoft.Extensions.FileProviders.Physical
export '../src/file_providers/providers/physical/exclusion_filters.dart';
export '../src/file_providers/providers/physical/physical_directory_contents.dart';
export '../src/file_providers/providers/physical/physical_directory_info.dart';
export '../src/file_providers/providers/physical/physical_file_info.dart';
export '../src/file_providers/providers/physical/physical_file_provider.dart';
export '../src/file_providers/providers/physical/physical_file_provider_options.dart';
export '../src/file_providers/providers/physical/physical_files_watcher.dart';
export '../src/file_providers/providers/physical/polling_file_change_token.dart';
export '../src/file_providers/providers/physical/polling_wildcard_change_token.dart';
export '../src/file_providers/providers/physical/x_file_info.dart';
