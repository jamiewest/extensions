/// An exception thrown when a file-based configuration source cannot be read.
///
/// This is a web-safe stand-in for `dart:io`'s `FileSystemException` so that
/// file-based configuration can be used on platforms without `dart:io`.
class FileSystemException implements Exception {
  /// Creates a [FileSystemException] with a [message] and optional [path].
  FileSystemException(this.message, [this.path]);

  /// A description of the error.
  final String message;

  /// The path of the file that triggered the error, if known.
  final String? path;

  @override
  String toString() {
    if (path == null) {
      return 'FileSystemException: $message';
    }
    return 'FileSystemException: $message, path = $path';
  }
}
