import '../primitives/change_token.dart';
import 'directory_contents.dart';
import 'file_info.dart';
import 'file_provider.dart';
import 'not_found_directory_contents.dart';
import 'not_found_file_info.dart';
import 'null_change_token.dart';

/// An empty file provider with no contents.
class NullFileProvider implements FileProvider {
  /// Enumerate a non-existent directory.
  @override
  DirectoryContents getDirectoryContents(String subpath) =>
      NotFoundDirectoryContents.singleton();

  /// Locate a non-existent file.
  @override
  FileInfo getfileInfo(String subpath) => NotFoundFileInfo(subpath);

  /// Returns a [ChangeToken] that monitors nothing.
  @override
  ChangeToken watch(String filter) => NullChangeToken.singleton();
}
