import 'file_info_base.dart';
import 'file_system_info_base.dart';

/// Enumerates all files and directories in the directory.
abstract class DirectoryInfoBase implements FileSystemInfoBase {
  /// Enumerates all files and directories in the directory.
  Iterable<FileSystemInfoBase> enumerateFileSystemInfos();

  /// Returns an instance of [DirectoryInfoBase] that represents a subdirectory
  DirectoryInfoBase? getDirectory(String path);

  /// Returns an instance of [FileInfoBase] that represents a file in the
  /// directory
  FileInfoBase? getFile(String path);
}
