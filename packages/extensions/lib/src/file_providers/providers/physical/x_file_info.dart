import 'dart:io' as io;
import 'dart:io' show File;

import 'package:cross_file/cross_file.dart';
import 'package:file/file.dart' show File;

import '../../../../file_providers.dart' show File;
import '../../file_info.dart';

/// Represents a file using cross_file's XFile for cross-platform support.
///
/// This implementation works on both VM and web platforms.
class XFileInfo implements FileInfo {
  final XFile _file;
  final io.File? _ioFile;

  /// Creates an [XFileInfo] from an [XFile].
  XFileInfo(this._file) : _ioFile = null;

  /// Creates an [XFileInfo] from a Dart IO [io.File].
  ///
  /// This constructor is only available on VM platforms.
  XFileInfo.fromFile(io.File file)
      : _file = XFile(file.path),
        _ioFile = file;

  @override
  bool get exists {
    // On VM platforms, use the IO file if available
    final ioFile = _ioFile;
    if (ioFile != null) {
      return ioFile.existsSync();
    }

    // On web, XFile.length returns a future, so we can't easily check existence
    // synchronously. We assume the file exists if we have an XFile instance.
    return true;
  }

  @override
  int get length {
    try {
      // For VM platforms with IO file
      final ioFile = _ioFile;
      if (ioFile != null) {
        return ioFile.lengthSync();
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
      // For VM platforms with IO file
      final ioFile = _ioFile;
      if (ioFile != null) {
        return ioFile.lastModifiedSync();
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
    // For VM platforms
    final ioFile = _ioFile;
    if (ioFile != null) {
      return ioFile.openRead();
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
