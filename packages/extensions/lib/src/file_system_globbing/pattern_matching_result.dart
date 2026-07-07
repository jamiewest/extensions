import 'file_pattern_match.dart';

/// Represents a collection of [FilePatternMatch]
class PatternMatchingResult {
  /// The collection of [FilePatternMatch]
  Iterable<FilePatternMatch> files;

  final bool _hasFiles;

  /// Initializes the result with a collection of [FilePatternMatch]
  PatternMatchingResult(this.files) : _hasFiles = files.isNotEmpty;

  /// Gets a value that determines if this instance of [PatternMatchingResult]
  /// has any matches.
  bool get hasFiles => _hasFiles;
}
