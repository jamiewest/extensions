class ExceptionBase implements Exception {
  final String? _message;
  final Exception? _innerException;
  final StackTrace? _stackTrace;
  final String _typeName;

  static const String innerExceptionString = ' ---> ';

  const ExceptionBase({
    String? message,
    Exception? innerException,
    StackTrace? stackTrace,
    String typeName = 'ExceptionBase',
  })  : _message = message ?? '',
        _innerException = innerException,
        _stackTrace = stackTrace,
        _typeName = typeName;

  /// The message that describes the current exception.
  String? get message =>
      _message ?? 'Exception of type \'${_getClassName()}\' was thrown.';

  /// The [Exception] instance that caused the current exception.
  Exception? get innerException => _innerException;

  /// The string representation of the immediate frames on the call stack.
  StackTrace? get stackTrace => _stackTrace;

  String _getClassName() => _typeName;
}
