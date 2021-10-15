import '../options/options.dart';
import '../shared/cancellation_token.dart';
import 'hosted_service.dart';
import 'validator_options.dart';

class ValidationHostedService implements HostedService {
  Map<Type, Function> _validators;

  ValidationHostedService(Options<ValidatorOptions> validatorOptions)
      : _validators = validatorOptions.value.validators;

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
      // TODO: Use rethrow here?
      // ExceptionDispatchInfo.Capture(exceptions[0]).Throw();
    }

    if (exceptions.length > 1) {
      // Aggregate if we have many errors
      // TODO: Create an AggregateException class
      // throw AggregateException(exceptions);
    }

    // TODO: Was Task.CompletedTask, use a Completer here?
    return Future.value(null);
  }

  @override
  Future<void> stop(CancellationToken cancellationToken) {
    // TODO: implement stop
    throw UnimplementedError();
  }
}
