import 'package:file/file.dart';
import 'package:path/path.dart' as p;

import 'directory_info_base.dart';
import 'file_info_base.dart';
import 'file_info_wrapper.dart';
import 'file_system_info_base.dart';

class DirectoryInfoWrapper implements DirectoryInfoBase {
  final Directory _directoryInfo;

  /// Initializes an instance of [DirectoryInfoWrapper].
  DirectoryInfoWrapper(Directory directoryInfo)
      : _directoryInfo = directoryInfo;

  @override
  Iterable<FileSystemInfoBase> enumerateFileSystemInfos() {
    var items = <FileSystemInfoBase>[];
    if (_directoryInfo.existsSync()) {
      var fileSystemInfos = <FileSystemEntity>[];
      try {
        fileSystemInfos.addAll(_directoryInfo.listSync(recursive: false));
      } on Exception {
        // Ignore exceptions when listing directory contents
      }

      for (var fileInfo in fileSystemInfos) {
        if (fileInfo is Directory) {
          items.add(DirectoryInfoWrapper(fileInfo));
        } else if (fileInfo is File) {
          items.add(FileInfoWrapper(fileInfo));
        }
      }
    }
    return items;
  }

  @override
  DirectoryInfoBase? getDirectory(String name) {
    var isParentPath = name == '..';

    if (isParentPath) {
      return DirectoryInfoWrapper(
        _directoryInfo.fileSystem.directory(p.join(fullName, name)),
      );
    }
    return null;
  }

  @override
  String get fullName => _directoryInfo.path;

  @override
  FileInfoBase? getFile(String name) =>
      FileInfoWrapper(_directoryInfo.fileSystem.file(p.join(fullName, name)));

  @override
  String get name => _directoryInfo.basename;

  @override
  DirectoryInfoBase get parentDirectory =>
      DirectoryInfoWrapper(_directoryInfo.parent);
}
