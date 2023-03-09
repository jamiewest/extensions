import 'file_info.dart';
import 'file_not_found_exception.dart';

/// Represents a non-existing file.
class NotFoundFileInfo implements FileInfo {
  final String _name;

  /// Initializes an instance of [NotFoundFileInfo].
  NotFoundFileInfo(String name) : _name = name;

  /// Always false.
  @override
  bool get exists => false;

  /// Always false.
  @override
  bool get isDirectory => false;

  /// Returns a negative infinity date value.
  @override
  DateTime get lastModified => DateTime.utc(-271821, 04, 20);

  /// Always equals -1.
  @override
  int get length => -1;

  @override
  String get name => _name;

  /// Always null.
  @override
  String? get physicalPath => null;

  /// Always throws. A stream cannot be created for a non-existing file.
  @override
  Stream<dynamic> createReadStream() => throw FileNotFoundException(name);
}
