import '../../directory_contents.dart';
import '../../file_info.dart';

/// Directory contents that aggregate multiple providers.
class CompositeDirectoryContents extends DirectoryContents {
  CompositeDirectoryContents(List<DirectoryContents> contents)
      : _contents = contents;

  final List<DirectoryContents> _contents;

  /// True if any underlying directory exists.
  @override
  bool get exists => _contents.any((c) => c.exists);

  @override
  Iterator<FileInfo> get iterator => _CompositeIterator(_contents);
}

class _CompositeIterator implements Iterator<FileInfo> {
  _CompositeIterator(this._collections)
      : _currentEnumerator = _collections.isNotEmpty
            ? _collections.first.iterator
            : <FileInfo>[].iterator;

  final List<DirectoryContents> _collections;
  int _index = 0;
  Iterator<FileInfo> _currentEnumerator;
  FileInfo? _current;
  final Set<String> _seenNames = <String>{};

  @override
  FileInfo get current => _current!;

  @override
  bool moveNext() {
    while (true) {
      if (_currentEnumerator.moveNext()) {
        var candidate = _currentEnumerator.current;
        // First provider wins per name.
        var key = candidate.name.toLowerCase();
        if (_seenNames.contains(key)) {
          continue;
        }
        _seenNames.add(key);
        _current = candidate;
        return true;
      }

      _index++;
      if (_index >= _collections.length) {
        _current = null;
        return false;
      }

      _currentEnumerator = _collections[_index].iterator;
    }
  }
}
