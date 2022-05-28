import 'dart:io';

import 'package:path/path.dart' as p;

import '../file_info.dart';

class PhysicalFileInfo implements FileInfo {
  final File _info;

  PhysicalFileInfo(this._info);

  @override
  bool get exists => _info.existsSync();

  @override
  int get length => _info.lengthSync();

  @override
  String? get physicalPath => _info.path;

  @override
  String get name => p.basename(_info.path);

  @override
  DateTime get lastModified => _info.lastModifiedSync();

  /// Always false.
  @override
  bool get isDirectory => false;

  @override
  Stream createReadStream() => _info.openRead(1);
}
