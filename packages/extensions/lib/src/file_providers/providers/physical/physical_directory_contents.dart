import 'package:file/file.dart';

import '../../directory_contents.dart';
import '../../file_info.dart';
import 'physical_directory_info.dart';

/// Represents the contents of a physical file directory
class PhysicalDirectoryContents extends DirectoryContents {
  final PhysicalDirectoryInfo _info;

  /// Initializes an instance of [PhysicalDirectoryContents] backed by
  /// [fileSystem] at [directory].
  PhysicalDirectoryContents(FileSystem fileSystem, String directory)
      : _info = PhysicalDirectoryInfo(fileSystem.directory(directory));

  @override
  bool get exists => _info.exists;

  @override
  Iterator<FileInfo> get iterator => _info.iterator;
}
