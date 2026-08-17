import 'package:path/path.dart' as p;

import 'abstractions/directory_info_base.dart';
import 'abstractions/file_info_base.dart';
import 'abstractions/file_system_info_base.dart';

/// Represents an in-memory directory for pattern matching without
/// accessing the file system.
///
/// Useful for testing glob patterns or matching against virtual file systems.
class InMemoryDirectoryInfo implements DirectoryInfoBase {
  final String _path;
  final List<FileSystemInfoBase> _children;
  final DirectoryInfoBase? _parent;

  /// Creates an in-memory directory with the specified path and children.
  InMemoryDirectoryInfo(
    String path, {
    List<FileSystemInfoBase>? files,
    this._parent,
  }) : _path = path,
       _children = files ?? [];

  /// Builds an in-memory directory tree rooted at [rootDir] from a flat
  /// list of file paths.
  ///
  /// Relative paths in [files] are resolved against [rootDir]; paths
  /// outside [rootDir] are ignored.
  factory InMemoryDirectoryInfo.fromPaths(
    String rootDir,
    Iterable<String>? files,
  ) {
    final rootPath = p.normalize(p.absolute(rootDir));
    final root = InMemoryDirectoryInfo(rootPath);
    final directories = <String, InMemoryDirectoryInfo>{'': root};
    for (final file in files ?? const <String>[]) {
      final fullPath = p.isAbsolute(file)
          ? p.normalize(file)
          : p.normalize(p.join(rootPath, file));
      if (!p.isWithin(rootPath, fullPath)) {
        continue;
      }

      final parts = p.split(p.relative(fullPath, from: rootPath));
      var directory = root;
      var relativePath = '';
      for (var i = 0; i < parts.length - 1; i++) {
        final parent = directory;
        relativePath = relativePath.isEmpty
            ? parts[i]
            : '$relativePath/${parts[i]}';
        directory = directories.putIfAbsent(relativePath, () {
          final child = InMemoryDirectoryInfo(
            p.join(parent.fullName, parts[i]),
            parent: parent,
          );
          parent._children.add(child);
          return child;
        });
      }
      directory._children.add(InMemoryFileInfo(fullPath, parent: directory));
    }
    return root;
  }

  @override
  String get fullName => _path;

  @override
  String get name => p.basename(_path);

  @override
  DirectoryInfoBase? get parentDirectory => _parent;

  @override
  DirectoryInfoBase? getDirectory(String path) {
    if (path == '..') {
      return _parent;
    }
    for (final child in _children) {
      if (child is DirectoryInfoBase && child.name == path) {
        return child;
      }
    }
    return null;
  }

  @override
  FileInfoBase? getFile(String path) {
    for (final child in _children) {
      if (child is FileInfoBase && child.name == path) {
        return child;
      }
    }
    return null;
  }

  @override
  Iterable<FileSystemInfoBase> enumerateFileSystemInfos() => _children;
}

/// Represents an in-memory file for pattern matching.
class InMemoryFileInfo implements FileInfoBase {
  final String _path;
  final DirectoryInfoBase? _parent;

  /// Creates an in-memory file with the specified path.
  InMemoryFileInfo(String path, {this._parent}) : _path = path;

  @override
  String get fullName => _path;

  @override
  String get name => p.basename(_path);

  @override
  DirectoryInfoBase? get parentDirectory => _parent;
}
