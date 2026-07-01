import 'package:cross_file/cross_file.dart';
import 'package:file/file.dart';

import '../../file_info.dart';

/// Represents a file using cross_file's XFile for cross-platform support.
///
/// This implementation works on both VM and web platforms.
class XFileInfo implements FileInfo {
  final XFile _file;
  final File? _backing;

  /// Creates an [XFileInfo] from an [XFile].
  XFileInfo(this._file) : _backing = null;

  /// Creates an [XFileInfo] from a `package:file` [File].
  ///
  /// The backing file enables synchronous access to length and modification
  /// time; without it those values are only available asynchronously.
  XFileInfo.fromFile(File file)
      : _file = XFile(file.path),
        _backing = file;

  @override
  bool get exists {
    // Use the synchronous backing file when available.
    final backing = _backing;
    if (backing != null) {
      return backing.existsSync();
    }

    // On web, XFile.length returns a future, so we can't easily check existence
    // synchronously. We assume the file exists if we have an XFile instance.
    return true;
  }

  @override
  int get length {
    try {
      // Use the synchronous backing file when available.
      final backing = _backing;
      if (backing != null) {
        return backing.lengthSync();
      }

      // For web, XFile.length returns a Future<int>, but we need sync access.
      // This is a limitation - on web, we return -1 to indicate unknown length.
      // Users should use lengthAsync() for web compatibility.
      return -1;
    } catch (e) {
      return -1;
    }
  }

  /// Gets the file length asynchronously (works on all platforms).
  Future<int> lengthAsync() => _file.length();

  @override
  String? get physicalPath => _file.path.isEmpty ? null : _file.path;

  @override
  String get name => _file.name;

  @override
  DateTime get lastModified {
    try {
      // Use the synchronous backing file when available.
      final backing = _backing;
      if (backing != null) {
        return backing.lastModifiedSync();
      }

      // For web, XFile.lastModified returns a Future<DateTime>, but we need
      // sync access. We return the current time as a fallback.
      // Users should use lastModifiedAsync() for web compatibility.
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  /// Gets the last modified time asynchronously (works on all platforms).
  Future<DateTime> lastModifiedAsync() => _file.lastModified();

  @override
  bool get isDirectory => false;

  @override
  Stream<dynamic> createReadStream() {
    // Use the synchronous backing file when available.
    final backing = _backing;
    if (backing != null) {
      return backing.openRead();
    }

    // For web platforms, we need to read the entire file and emit it
    // as a stream. This is less efficient than a true stream, but works
    // cross-platform.
    return Stream.fromFuture(_file.readAsBytes())
        .map((bytes) => bytes as dynamic);
  }

  /// Reads the file as a string (cross-platform).
  Future<String> readAsString() => _file.readAsString();

  /// Reads the file as bytes (cross-platform).
  Future<List<int>> readAsBytes() => _file.readAsBytes();

  /// Gets the MIME type of the file (cross-platform).
  String? get mimeType => _file.mimeType;
}
