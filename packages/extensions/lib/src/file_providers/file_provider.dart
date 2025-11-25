import '../primitives/change_token.dart';
import 'directory_contents.dart';
import 'file_info.dart';

/// A read-only file provider abstraction.
abstract class FileProvider {
  /// Locate a file at the given path.
  FileInfo getFileInfo(String subpath);

  /// Enumerate a directory at the given path, if any.
  DirectoryContents getDirectoryContents(String subpath);

  /// Creates an [IChangeToken] for the specified [filter].
  IChangeToken watch(String filter);
}

// /// A read-only file provider abstraction.
// class FileProvider {
//   final FileSystem _fileSystem;

//   FileProvider(this._fileSystem);

//   /// Locate a file at the given path.
//   FileInfo? getfileInfo(String subpath) => FileInfo(_fileSystem.file(subpath));

//   /// Enumerate a directory at the given path, if any.
//   DirectoryContents? getDirectoryContents(String subpath) => DirectoryContents(
//         _fileSystem
//             .directory(subpath)
//             .listSync()
//             .map(
//               (e) => FileInfo(e),
//             )
//             .toList(),
//       );

//   /// Creates a [ChangeToken] for the specified [filter].
//   ChangeToken? watch(String filter) {}
// }
