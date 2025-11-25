import 'package:file/file.dart';
import 'package:path/path.dart' as p;

extension FileSystemEntityExtensions on FileSystemEntity {
  String get name => p.basename(path);
}
