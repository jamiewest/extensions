import 'dart:collection';

import 'file_info.dart';

/// Represents a directory's content in the file provider.
abstract class DirectoryContents with IterableMixin<FileInfo> {
  /// True if a directory was located at the given path.
  bool get exists;
}
