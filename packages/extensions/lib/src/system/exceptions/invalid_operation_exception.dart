import 'system_exception.dart';

/// The exception that is thrown when a method call is invalid for the
/// object's current state.
class InvalidOperationException extends SystemException {
  InvalidOperationException({
    super.message =
        'Operation is not valid due to the current state of the object.',
    super.innerException,
    super.stackTrace,
  });
}
