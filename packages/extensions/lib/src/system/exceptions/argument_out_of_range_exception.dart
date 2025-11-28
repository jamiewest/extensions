import 'argument_exception.dart';

/// The exception that is thrown when the value of an argument is outside
/// the allowable range of values as defined by the invoked method.
class ArgumentOutOfRangeException extends ArgumentException {
  final Object? _actualValue;

  ArgumentOutOfRangeException({
    super.message = 'Value cannot be null.',
    super.innerException,
    super.stackTrace,
    super.paramName,
    Object? actualValue,
  }) : _actualValue = actualValue;

  Object? get actualValue => _actualValue;

  @override
  String? get message {
    var s = super.message!;
    if (_actualValue != null) {
      s += ' (Actual value: $_actualValue)';
    }
    return s;
  }

  /// Throws an [ArgumentOutOfRangeException] if the value is zero.
  static void throwZero<T>(T value, String? paramName) {
    throw ArgumentOutOfRangeException(
      message: "$paramName ('$value') must be a non-zero value.",
      paramName: paramName,
      actualValue: value,
    );
  }

  static void ThrowNegative<T>(T value, String? paramName) {}

  static void ThrowNegativeOrZero<T>(T value, String? paramName) {}
}
