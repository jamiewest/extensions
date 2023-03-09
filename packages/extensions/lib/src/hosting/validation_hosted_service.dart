import '../options/options.dart';
import '../primitives/cancellation_token.dart';
import '../primitives/void_callback.dart';
import 'hosted_service.dart';
import 'validator_options.dart';

class ValidationHostedService implements HostedService {
  final Map<Type, VoidCallback> _validators;

  ValidationHostedService(Options<ValidatorOptions> validatorOptions)
      : _validators = validatorOptions.value!.validators;

  @override
  Future<void> start(CancellationToken cancellationToken) {
    var exceptions = <Exception>[];
    for (var validate in _validators.values) {
      try {
        // Execute the validation method and catch the validation error.
        validate();
      } catch (e) {
        exceptions.add(e as Exception);
      }
    }

    if (exceptions.length == 1) {
      // Rethrow if it's a single error.
      // ExceptionDispatchInfo.Capture(exceptions[0]).Throw();
    }

    if (exceptions.length > 1) {
      // Aggregate if we have many errors
      // throw AggregateException(exceptions);
    }

    return Future.value();
  }

  @override
  Future<void> stop(CancellationToken cancellationToken) => Future.value();
}
