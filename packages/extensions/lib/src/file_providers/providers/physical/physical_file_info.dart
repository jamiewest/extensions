import 'package:file/file.dart';

import '../../file_info.dart';
import 'file_system_entity_extensions.dart';

/// Represents a file on a physical filesystem
class PhysicalFileInfo implements FileInfo {
  final File _info;

  /// Initializes an instance of [PhysicalFileInfo] that wraps an instance
  /// of [File].
  PhysicalFileInfo(this._info);

  @override
  bool get exists => _info.existsSync();

  @override
  int get length => _info.lengthSync();

  @override
  String? get physicalPath => _info.path;

  @override
  String get name => _info.name;

  @override
  DateTime get lastModified => _info.lastModifiedSync();

  /// Always false.
  @override
  bool get isDirectory => false;

  @override
  Stream<dynamic> createReadStream() => _info.openRead();
}
