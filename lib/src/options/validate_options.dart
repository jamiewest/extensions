import 'validate_options_result.dart';

typedef ValidationCallback<TOptions> = bool Function(TOptions options);

class ValidateOptions<TOptions> {
  final String _name;
  final ValidationCallback<TOptions>? _validation;
  final String _failureMessage;

  const ValidateOptions(
    String name,
    ValidationCallback<TOptions>? validation,
    String failureMessage,
  )   : _name = name,
        _validation = validation,
        _failureMessage = failureMessage;

  ValidateOptionsResult? validate(String name, TOptions options) {
    // null name is used to configure all named options
    if (_name == name || name == _name) {
      if (_validation != null) {
        if (_validation!.call(options)) {
          return ValidateOptionsResult.success;
        }
      }

      return ValidateOptionsResult.fail([_failureMessage]);
    }

    // ignored if not validating this instance
    return ValidateOptionsResult.skip;
  }
}

// /// Interface used to validate options.
// abstract class IValidateOptions<TOptions> {
//   /// Validates a specific named options instance (or all when name is null).
//   ValidateOptionsResult? validate(String name, TOptions options);
// }

// class ValidateOptions<TOptions> implements IValidateOptions<TOptions> {
//   const ValidateOptions(
//     this.name,
//     this.validation,
//     this.failureMessage,
//   );

//   /// The options name;
//   final String name;

//   /// The validation function.
//   final ValidationCallback<TOptions>? validation;

//   /// The error to return when validation fails.
//   final String failureMessage;

//   /// Validates a specific named options instance (or all when [name] is null)
//   @override
//   ValidateOptionsResult? validate(String name, TOptions options) {
//     // null name is used to configure all named options
//     if (this.name == name || name == this.name) {
//       if (validation != null) {
//         if (validation!.call(options)) {
//           return ValidateOptionsResult.success;
//         }
//       }

//       return ValidateOptionsResult.fail([failureMessage]);
//     }

//     // ignored if not validating this instance
//     return ValidateOptionsResult.skip;
//   }
// }
