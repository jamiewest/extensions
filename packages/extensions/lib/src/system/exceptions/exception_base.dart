class ExceptionBase implements Exception {
  final String? _message;
  final Exception? _innerException;
  final StackTrace? _stackTrace;

  static const String innerExceptionString = ' ---> ';

  const ExceptionBase({
    String? message,
    Exception? innerException,
    StackTrace? stackTrace,
  })  : _message = message ?? '',
        _innerException = innerException,
        _stackTrace = stackTrace;

  /// The message that describes the current exception.
  String? get message =>
      _message ?? 'Exception of type \'${_getClassName()}\' was thrown.';

  /// The [Exception] instance that caused the current exception.
  Exception? get innerException => _innerException;

  /// The string representation of the immediate frames on the call stack.
  StackTrace? get stackTrace => _stackTrace;

  String _getClassName() => runtimeType.toString();
}
