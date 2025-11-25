import 'package:file/local.dart';
import 'package:path/path.dart' as p;

import '../../../primitives/change_token.dart';
import '../../../system/disposable.dart';
import '../../directory_contents.dart';
import '../../file_info.dart';
import '../../file_provider.dart';
import '../../not_found_directory_contents.dart';
import '../../not_found_file_info.dart';
import 'internal/path_utils.dart';
import 'physical_directory_contents.dart';
import 'physical_file_info.dart';
import 'physical_file_provider_options.dart';
import 'physical_files_watcher.dart';

/// Looks up files using the on-disk file system.
///
/// This provider supports file change notifications and exclusion filters.
class PhysicalFileProvider implements FileProvider, Disposable {
  final String _root;
  final PhysicalFilesWatcher _watcher;
  final PhysicalFileProviderOptions options;

  /// Creates a new instance of [PhysicalFileProvider] at the given
  /// root directory.
  ///
  /// The [root] path must be an absolute path.
  PhysicalFileProvider(
    String root, {
    PhysicalFileProviderOptions? options,
  })  : _root = p.absolute(root),
        options = options ?? PhysicalFileProviderOptions(),
        _watcher = PhysicalFilesWatcher(
          p.absolute(root),
          !(options?.usePollingFileWatcher ?? false),
        ) {
    if (!p.isAbsolute(root)) {
      throw ArgumentError.value(
        root,
        'root',
        'Root path must be an absolute path.',
      );
    }
  }

  PhysicalFilesWatcher get watcher => _watcher;

  /// The root directory for this instance.
  String get root => _root;

  @override
  FileInfo getFileInfo(String subpath) {
    var path = subpath.trimLeft().replaceFirst(p.separator, '');

    if (p.isRootRelative(path)) {
      return NotFoundFileInfo(path);
    }

    final fullPath = _getFullPath(path);
    if (fullPath == null) {
      return NotFoundFileInfo(path);
    }

    var fileInfo = const LocalFileSystem().file(path);

    return PhysicalFileInfo(fileInfo);
  }

  String? _getFullPath(String path) {
    if (PathUtils.pathNavigatesAboveRoot(path)) {
      return null;
    }

    String fullPath;

    try {
      fullPath = p.join(root, path);
    } on Exception {
      return null;
    }

    if (!_isUnderneathRoot(fullPath)) {
      return null;
    }

    return fullPath;
  }

  bool _isUnderneathRoot(String fullPath) => fullPath.startsWith(root);

  @override
  DirectoryContents getDirectoryContents(String subpath) {
    try {
      var path = subpath.trimLeft().replaceFirst(p.separator, '');

      if (p.isRootRelative(path)) {
        return NotFoundDirectoryContents();
      }

      final fullPath = _getFullPath(path);
      if (fullPath == null) {
        return NotFoundDirectoryContents();
      }

      return PhysicalDirectoryContents(fullPath);
    } catch (e) {
      return NotFoundDirectoryContents();
    }
  }

  @override
  IChangeToken watch(String filter) => _watcher.createFileChangeToken(filter);

  @override
  void dispose() {
    _watcher.dispose();
  }
}
