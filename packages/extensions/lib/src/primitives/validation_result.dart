class ValidationResult {
  final List<String> _memberNames = [];

  ValidationResult({
    this.errorMessage,
    Iterable<String>? memberNames,
  }) {
    if (memberNames != null) {
      _memberNames.addAll(memberNames);
    }
  }

  static final ValidationResult success = ValidationResult();

  /// Constructor that creates a copy of an existing ValidationResult.
  factory ValidationResult.from(ValidationResult result) => ValidationResult(
        errorMessage: result.errorMessage,
        memberNames: result.memberNames,
      );

  /// Gets the collection of member names affected by this result.
  /// The collection may be empty but will never be null.
  List<String> get memberNames => _memberNames;

  /// Gets the error message for this result.  It may be null.
  String? errorMessage;

  @override
  String toString() => errorMessage ?? '';
}
