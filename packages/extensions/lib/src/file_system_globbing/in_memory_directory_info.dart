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
    DirectoryInfoBase? parent,
  })  : _path = path,
        _children = files ?? [],
        _parent = parent;

  @override
  String get fullName => _path;

  @override
  String get name {
    final parts = _path.split('/');
    return parts.isEmpty ? '' : parts.last;
  }

  @override
  DirectoryInfoBase? get parentDirectory => _parent;

  @override
  DirectoryInfoBase? getDirectory(String path) {
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
  InMemoryFileInfo(String path, {DirectoryInfoBase? parent})
      : _path = path,
        _parent = parent;

  @override
  String get fullName => _path;

  @override
  String get name {
    final parts = _path.split('/');
    return parts.isEmpty ? '' : parts.last;
  }

  @override
  DirectoryInfoBase? get parentDirectory => _parent;
}
