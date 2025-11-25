import '../string.dart' as string;
import 'invalid_operation_exception.dart';

/// /// The exception that is thrown when accessing an object that was disposed.
class ObjectDisposedException extends InvalidOperationException {
  final String? _objectName;

  ObjectDisposedException({
    super.message = 'Cannot access a disposed object.',
    super.innerException,
    super.stackTrace,
    String? objectName,
  }) : _objectName = objectName;

  /// Gets the text for the message for this exception.
  @override
  String? get message {
    final name = objectName;
    if (string.isNullOrEmpty(name)) {
      return super.message;
    }

    final objectDisposed = 'Object name: \'$objectName\'.';
    return '${super.message!}\n$objectDisposed';
  }

  String get objectName => _objectName ?? '';
}
