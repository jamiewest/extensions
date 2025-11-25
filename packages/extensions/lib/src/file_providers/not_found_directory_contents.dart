import 'directory_contents.dart';
import 'file_info.dart';

/// Represents a non-existing directory
class NotFoundDirectoryContents extends DirectoryContents {
  NotFoundDirectoryContents() : super(<FileInfo>[]);

  /// A shared instance of [NotFoundDirectoryContents]
  factory NotFoundDirectoryContents.singleton() => NotFoundDirectoryContents();

  /// Always false.
  @override
  bool get exists => false;

  /// Returns an enumerator that iterates through the collection.
  @override
  Iterator<FileInfo> get iterator => const Iterable<FileInfo>.empty().iterator;
}
