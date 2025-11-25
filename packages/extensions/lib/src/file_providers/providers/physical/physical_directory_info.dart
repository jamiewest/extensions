import 'package:file/file.dart';

import '../../../system/exceptions/invalid_operation_exception.dart';
import '../../directory_contents.dart';
import '../../file_info.dart';
import 'physical_file_info.dart';

/// Represents a directory on a physical filesystem
class PhysicalDirectoryInfo extends DirectoryContents implements FileInfo {
  final Directory _info;
  Iterable<FileInfo>? _entries;

  /// Initializes an instance of [PhysicalDirectoryInfo]
  /// that wraps an instance of [Directory].
  PhysicalDirectoryInfo(Directory info) : _info = info;

  @override
  bool get exists => _info.existsSync();

  /// Always equals -1.
  @override
  int get length => -1;

  @override
  String? get physicalPath => _info.path;

  @override
  String get name => _info.path.split('/').last;

  /// The time when the directory was last written to.
  @override
  DateTime get lastModified => _info.statSync().modified.toUtc();

  /// Always true.
  @override
  bool get isDirectory => true;

  /// Always throws an exception because read streams are
  /// not supported on directories.
  @override
  Stream<dynamic> createReadStream() {
    throw InvalidOperationException(message: 'SR.CannotCreateStream');
  }

  @override
  Iterator<FileInfo> get iterator {
    _ensureInitialized();
    return _entries!.iterator;
  }

  void _ensureInitialized() {
    _entries = _info.listSync().map((e) => switch (e) {
          (File file) => PhysicalFileInfo(file),
          (Directory dir) => PhysicalDirectoryInfo(dir),
          _ => throw Exception(),
        });
  }
}
