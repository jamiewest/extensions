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
  Stream<dynamic> createReadStream();
}

// /// Represents a file in the given file provider.
// class FileInfo {
//   final f.FileSystemEntity _file;

//   FileInfo(this._file);

//   /// True if resource exists in the underlying storage system.
//   bool get exists => _file.existsSync();

//   /// The length of the file in bytes, or -1 for a directory
//   /// or non-existing files.
//   int get length => _file is f.File ? _file.lengthSync() : -1;

//   /// The path to the file, including the file name. Return
//   /// null if the file is not directly accessible.
//   String? get physicalPath => _file.path;

//   /// The name of the file or directory, not including any path.
//   String get name => p.basename(_file.path);

//   /// When the file was last modified
//   DateTime get lastModified => _file is f.File
//       ? _file.lastModifiedSync()
//       : _file.statSync().modified.toUtc();

//   /// True for the case `TryGetDirectoryContents` has enumerated a sub-directory
//   bool get isDirectory => _file is f.Directory;

//   /// Return file contents as readonly stream. Caller should dispose stream
//   /// when complete.
//   Stream<dynamic> createReadStream() => _file is f.File
//       ? _file.openRead(1)
//       : throw Exception('Cannot create a stream for a directory.');
// }
