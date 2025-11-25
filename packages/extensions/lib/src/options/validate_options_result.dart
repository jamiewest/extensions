/// Represents the result of an options validation.
class ValidateOptionsResult {
  /// Result when validation was skipped due to name not matching.
  static ValidateOptionsResult skip = ValidateOptionsResult()..skipped = true;

  /// Validation was successful.
  static ValidateOptionsResult success = ValidateOptionsResult()
    ..succeeded = true;

  /// Returns a failure result.
  static ValidateOptionsResult fail(Iterable<String> failures) =>
      ValidateOptionsResult()
        ..failed = true
        ..failureMessage = failures.join('; ')
        ..failures = failures;

  /// True if validation was successful.
  late bool succeeded;

  /// True if validation was not run.
  late bool skipped;

  /// True if validation failed.
  bool failed = false;

  /// Used to describe why validation failed.
  late String failureMessage;

  /// Full list of failures (can be multiple).
  late Iterable<String> failures;
}
