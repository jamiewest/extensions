import 'dart:io';

import '../file_info.dart';

/// Represents a directory on a physical filesystem
class PhysicalDirectoryInfo implements FileInfo {
  final Directory _info;

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
  Stream createReadStream() {
    throw Exception('SR.CannotCreateStream');
  }
}
