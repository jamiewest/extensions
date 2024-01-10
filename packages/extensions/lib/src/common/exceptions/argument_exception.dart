import '../../../common.dart';

/// The exception that is thrown when one of the arguments provided
/// to a method is not valid.
class ArgumentException extends SystemException {
  final String? _paramName;

  ArgumentException({
    super.message = 'Value does not fall within the expected range',
    super.innerException,
    super.stackTrace,
    String? paramName,
  }) : _paramName = paramName;

  String? get paramName => _paramName;

  @override
  String? get message {
    String s = super.message ?? '';
    if (paramName != null) {
      s += ' (Parameter \'$paramName\')';
    }

    return s;
  }

  /// Throws an exception if [argument] is null or empty.
  static void throwIfNullOrEmpty(String? argument, String? paramName) {
    if (isNullOrEmpty(argument)) {
      _throwNullOrEmptyException(argument, paramName);
    }
  }

  /// Throws an exception if <paramref name="argument"/> is null, empty, or consists only of white-space characters.
  static void throwIfNullOrWhitespace(String? argument, String? paramName) {
    if (isNullOrWhitespace(argument)) {
      _throwNullOrWhitespaceException(argument, paramName);
    }
  }

  static void _throwNullOrEmptyException(String? argument, String? paramName) {
    ArgumentNullException.throwIfNull(argument, paramName);
    throw ArgumentException(
      message: 'The value cannot be an empty string.',
      paramName: paramName,
    );
  }

  static void _throwNullOrWhitespaceException(
      String? argument, String? paramName) {
    ArgumentNullException.throwIfNull(argument, paramName);
    throw ArgumentException(
      message: 'The value cannot be an empty string or '
          'composed entirely of whitespace.',
      paramName: paramName,
    );
  }
}
