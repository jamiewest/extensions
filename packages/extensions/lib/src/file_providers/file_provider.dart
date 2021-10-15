import '../primitives/change_token.dart';
import 'directory_contents.dart';
import 'file_info.dart';

/// A read-only file provider abstraction.
abstract class FileProvider {
  /// Locate a file at the given path.
  FileInfo? getfileInfo(String subpath);

  /// Enumerate a directory at the given path, if any.
  DirectoryContents? getDirectoryContents(String subpath);

  /// Creates a [ChangeToken] for the specified [filter].
  ChangeToken? watch(String filter);
}
