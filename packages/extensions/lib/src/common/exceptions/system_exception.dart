import 'exception_base.dart';

/// This class is provided as a means to differentiate between system
/// exceptions and application exceptions.
class SystemException extends ExceptionBase {
  const SystemException({
    super.message = 'System error.',
    super.innerException,
    super.stackTrace,
  });
}
