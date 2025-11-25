/// Represents a file that was matched by searching using a globbing pattern
class FilePatternMatch {
  final String _path;
  final String? _stem;

  /// Initializes new instance of [FilePatternMatch]
  FilePatternMatch(String path, [String? stem])
      : _path = path,
        _stem = stem;

  /// The path to the file matched, relative to the beginning of the
  /// matching search pattern.
  String get path => _path;

  /// The subpath to the file matched, relative to the first wildcard
  /// in the matching search pattern.
  String? get stem => _stem;
}
