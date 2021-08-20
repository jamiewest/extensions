/// Thrown when options validation fails.
class OptionsValidationException implements Exception {
  final Iterable<String> _failures;

  OptionsValidationException(
    this.optionsName,
    this.optionsType,
    Iterable<String>? failureMessages,
  ) : _failures = failureMessages ?? <String>[];

  final String optionsName;

  final Type optionsType;

  Iterable<String> get failures => _failures;

  String message() => failures.join('; ');
}
