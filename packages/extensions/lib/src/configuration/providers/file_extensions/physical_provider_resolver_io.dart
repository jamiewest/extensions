import 'dart:io' as io;

import 'package:path/path.dart' as p;

import '../../../file_providers/file_provider.dart';
import '../../../file_providers/providers/physical/physical_file_provider.dart';

/// A resolved physical provider and the file path relative to it.
typedef ResolvedProvider = ({FileProvider provider, String path});

/// The current working directory path.
String currentDirectoryPath() => io.Directory.current.path;

/// Whether a file exists at [path] on disk.
bool fileExistsSync(String path) => io.File(path).existsSync();

/// Resolves a [FileProvider] for the nearest existing ancestor directory of the
/// absolute [path].
///
/// Returns the provider together with the file path made relative to that
/// directory, or `null` if no existing ancestor directory is found.
ResolvedProvider? resolvePhysicalProvider(String path) {
  if (!p.isAbsolute(path)) {
    return null;
  }

  String? directory = p.dirname(path);
  String? pathToFile = p.basename(path);

  while (directory != null &&
      directory.isNotEmpty &&
      !io.Directory(directory).existsSync()) {
    pathToFile = p.join(p.basename(directory), pathToFile);
    directory = p.dirname(directory);
  }

  if (directory != null &&
      directory.isNotEmpty &&
      io.Directory(directory).existsSync()) {
    return (provider: PhysicalFileProvider(directory), path: pathToFile!);
  }

  return null;
}
