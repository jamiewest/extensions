/// The result of testing a file against a pattern context.
///
/// This API supports infrastructure and is not intended to be used directly.
class PatternTestResult {
  /// The shared failure result.
  static final PatternTestResult failed = PatternTestResult._(
    isSuccessful: false,
    stem: null,
  );

  /// Whether the file matched the pattern.
  final bool isSuccessful;

  /// The portion of the matched path relative to the first wildcard, or
  /// `null` when the test failed.
  final String? stem;

  PatternTestResult._({required this.isSuccessful, required this.stem});

  /// Creates a successful result carrying [stem].
  factory PatternTestResult.success(String? stem) =>
      PatternTestResult._(isSuccessful: true, stem: stem);
}
