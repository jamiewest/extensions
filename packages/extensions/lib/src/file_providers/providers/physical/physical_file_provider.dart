import 'package:file/file.dart';
import 'package:path/path.dart' as p;

import '../../../primitives/change_token.dart';
import '../../../system/disposable.dart';
import '../../directory_contents.dart';
import '../../file_info.dart';
import '../../file_provider.dart';
import '../../not_found_directory_contents.dart';
import '../../not_found_file_info.dart';
import 'default_file_system.dart';
import 'internal/path_utils.dart';
import 'physical_directory_contents.dart';
import 'physical_file_info.dart';
import 'physical_file_provider_options.dart';
import 'physical_files_watcher.dart';

/// Looks up files using the on-disk file system.
///
/// This provider supports file change notifications and exclusion filters. By
/// default it is backed by the platform filesystem (a `LocalFileSystem` on
/// VM/native, an empty `MemoryFileSystem` on web); pass [fileSystem] to supply
/// a seeded in-memory filesystem or any other `package:file` implementation.
class PhysicalFileProvider implements FileProvider, Disposable {
  final FileSystem _fileSystem;
  final String _root;
  final PhysicalFilesWatcher _watcher;
  final PhysicalFileProviderOptions options;

  /// Creates a new instance of [PhysicalFileProvider] at the given
  /// root directory.
  ///
  /// The [root] path must be an absolute path for [fileSystem].
  factory PhysicalFileProvider(
    String root, {
    FileSystem? fileSystem,
    PhysicalFileProviderOptions? options,
  }) {
    final fs = fileSystem ?? defaultFileSystem();
    final opts = options ?? PhysicalFileProviderOptions();

    if (!fs.path.isAbsolute(root)) {
      throw ArgumentError.value(
        root,
        'root',
        'Root path must be an absolute path.',
      );
    }

    return PhysicalFileProvider._(fs, fs.path.absolute(root), opts);
  }

  PhysicalFileProvider._(
    FileSystem fileSystem,
    String root,
    PhysicalFileProviderOptions options,
  )   : _fileSystem = fileSystem,
        _root = root,
        options = options,
        _watcher = PhysicalFilesWatcher(
          fileSystem,
          root,
          !options.usePollingFileWatcher,
          pollingInterval: options.pollingInterval,
        );

  /// The filesystem backing this provider.
  FileSystem get fileSystem => _fileSystem;

  PhysicalFilesWatcher get watcher => _watcher;

  /// The root directory for this instance.
  String get root => _root;

  p.Context get _path => _fileSystem.path;

  @override
  FileInfo getFileInfo(String subpath) {
    var path = subpath.trim();

    // Remove leading separator if present
    if (path.startsWith(_path.separator)) {
      path = path.substring(_path.separator.length);
    }

    if (_path.isRootRelative(path)) {
      return NotFoundFileInfo(path);
    }

    final fullPath = _getFullPath(path);
    if (fullPath == null) {
      return NotFoundFileInfo(path);
    }

    return PhysicalFileInfo(_fileSystem.file(fullPath));
  }

  String? _getFullPath(String path) {
    if (PathUtils.pathNavigatesAboveRoot(path, _path)) {
      return null;
    }

    String fullPath;

    try {
      fullPath = _path.join(root, path);
    } on Exception {
      return null;
    }

    if (!_isUnderneathRoot(fullPath)) {
      return null;
    }

    return fullPath;
  }

  bool _isUnderneathRoot(String fullPath) {
    if (!fullPath.startsWith(root)) {
      return false;
    }

    // Ensure the path is truly under the root, not just a prefix match
    // e.g., root="/tmp/foo" should not match fullPath="/tmp/foobar"
    if (fullPath.length == root.length) {
      return true; // Exact match
    }

    // The character after root must be a separator
    return fullPath[root.length] == _path.separator;
  }

  @override
  DirectoryContents getDirectoryContents(String subpath) {
    try {
      var path = subpath.trim();

      // Remove leading separator if present
      if (path.startsWith(_path.separator)) {
        path = path.substring(_path.separator.length);
      }

      if (_path.isRootRelative(path)) {
        return NotFoundDirectoryContents();
      }

      final fullPath = _getFullPath(path);
      if (fullPath == null) {
        return NotFoundDirectoryContents();
      }

      return PhysicalDirectoryContents(_fileSystem, fullPath);
    } catch (e) {
      return NotFoundDirectoryContents();
    }
  }

  @override
  ChangeToken watch(String filter) => _watcher.createFileChangeToken(filter);

  @override
  void dispose() {
    _watcher.dispose();
  }
}
