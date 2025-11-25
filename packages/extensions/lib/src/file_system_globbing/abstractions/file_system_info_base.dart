import 'directory_info_base.dart';

/// Shared abstraction for files and directories
abstract class FileSystemInfoBase {
  /// A string containing the name of the file or directory
  String get name;

  /// A string containing the full path of the file or directory
  String get fullName;

  /// The parent directory for the current file or directory
  DirectoryInfoBase? get parentDirectory;
}
