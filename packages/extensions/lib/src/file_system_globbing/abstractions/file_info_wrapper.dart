import 'package:file/file.dart';

import '../../file_providers/providers/physical/file_system_entity_extensions.dart';
import 'directory_info_base.dart';
import 'directory_info_wrapper.dart';
import 'file_info_base.dart';

class FileInfoWrapper implements FileInfoBase {
  final File _fileInfo;

  FileInfoWrapper(File fileInfo) : _fileInfo = fileInfo;

  @override
  String get fullName => _fileInfo.path;

  @override
  String get name => _fileInfo.name;

  @override
  DirectoryInfoBase? get parentDirectory =>
      DirectoryInfoWrapper(_fileInfo.parent);
}
