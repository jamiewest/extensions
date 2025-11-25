import 'options.dart';
import 'startup_validator_options.dart';
import 'validate_options.dart';

/// Interface used by hosts to validate options during startup.
/// Options are enabled to be validated during startup by calling
/// [OptionsBuilderExtensions.validateOnStart()].
class StartupValidator {
  final StartupValidatorOptions _validatorOptions;

  StartupValidator({
    required Options<StartupValidatorOptions> validators,
  }) : _validatorOptions = validators.value!;

  /// Calls the [ValidateOptions] validators.
  void validate() {
    var exceptions = <Exception>[];

    for (var validator in _validatorOptions.validators.values) {
      try {
        validator();
      } on Exception catch (ex) {
        exceptions.add(ex);
      }
    }

    if (exceptions.isEmpty) {
      if (exceptions.length == 1) {
        throw exceptions.first;
      }

      if (exceptions.length > 1) {
        //throw AggregateException.from(exceptions);
      }
    }
  }
}
