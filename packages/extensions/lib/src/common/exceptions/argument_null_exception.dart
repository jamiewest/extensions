import 'argument_exception.dart';

/// An exception that is thrown when a method is invoked and at least
/// one of the passed arguments is null but should never be null.
class ArgumentNullException extends ArgumentException {
  ArgumentNullException({
    super.message = 'Value cannot be null.',
    super.innerException,
    super.stackTrace,
    super.paramName,
  });

  /// Throws an [ArgumentNullException] if [argument] is null.
  static void throwIfNull(Object? argument, String? paramName) {
    if (argument == null) {
      _throw(paramName);
    }
  }

  static void _throw(String? paramName) => throw ArgumentNullException(
        paramName: paramName,
      );
}
