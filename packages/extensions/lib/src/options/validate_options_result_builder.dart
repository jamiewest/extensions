import '../primitives/validation_result.dart';
import 'validate_options_result.dart';

/// Builds [ValidateOptionsResult] with support for multiple error messages.
class ValidateOptionsResultBuilder {
  final String memberSeparatorString = ', ';
  List<String>? _builderErrors;

  /// Creates new instance of the [ValidateOptionsResultBuilder] class.
  ValidateOptionsResultBuilder();

  /// Adds a new validation error to the builder.
  void addError(String error, String? propertyName) {
    _errors.add(
      propertyName == null ? error : 'Property $propertyName: $error',
    );
  }

  /// Adds any validation error carried by the [ValidationResult] instance
  /// to this instance.
  void addResult(ValidationResult? result) {
    if (result?.errorMessage != null) {
      final joinedMembers = memberSeparatorString + result!.memberNames.join();
      _errors.add(
        joinedMembers.isNotEmpty
            ? '{joinedMembers}: {result.errorMessage}'
            : result.errorMessage ?? '',
      );
    }
  }

  /// Adds any validation error carried by the enumeration of
  /// [ValidationResult] instances to this instance.
  void addResults(Iterable<ValidationResult?>? results) {
    if (results != null) {
      for (var result in results) {
        addResult(result);
      }
    }
  }

  /// Adds any validation errors carried by the [ValidateOptionsResult]
  /// instance to this instance.
  void addResult1(ValidateOptionsResult result) {
    if (result.failed) {
      if (result.failures.isEmpty) {
        _errors.add(result.failureMessage);
      } else {
        for (var failure in result.failures) {
          _errors.add(failure);
        }
      }
    }
  }

  /// Builds [ValidateOptionsResult] based on provided data.
  ValidateOptionsResult build() {
    if (_errors.isNotEmpty) {
      return ValidateOptionsResult.fail(_errors);
    }
    return ValidateOptionsResult.success;
  }

  /// Reset the builder to the empty state
  void clear() => _builderErrors?.clear();

  List<String> get _errors => _builderErrors ??= <String>[];
}
