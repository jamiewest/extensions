/// Represents a file in the given file provider.
abstract class FileInfo {
  /// True if resource exists in the underlying storage system.
  bool get exists;

  /// The length of the file in bytes, or -1 for a directory
  /// or non-existing files.
  int get length;

  /// The path to the file, including the file name. Return
  /// null if the file is not directly accessible.
  String? get physicalPath;

  /// The name of the file or directory, not including any path.
  String get name;

  /// When the file was last modified
  DateTime get lastModified;

  /// True for the case `TryGetDirectoryContents` has enumerated a sub-directory
  bool get isDirectory;

  /// Return file contents as readonly stream. Caller should dispose stream
  /// when complete.
  Stream createReadStream();
}
