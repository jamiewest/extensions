import 'file_pattern_match.dart';

/// Represents a collection of [FilePatternMatch]
class PatternMatchingResult {
  Iterable<FilePatternMatch> _files;
  final bool _hasFiles;

  /// Initializes the result with a collection of [FilePatternMatch]
  PatternMatchingResult(Iterable<FilePatternMatch> files)
      : _files = files,
        _hasFiles = files.isNotEmpty;

  /// Gets a collection of [FilePatternMatch]
  Iterable<FilePatternMatch> get files => _files;

  /// Sets a collection of [FilePatternMatch]
  set files(Iterable<FilePatternMatch> value) => _files = files;

  /// Gets a value that determines if this instance of [PatternMatchingResult]
  /// has any matches.
  bool get hasFiles => _hasFiles;
}
