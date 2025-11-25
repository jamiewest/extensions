import '../system/exceptions/exception_base.dart';
import 'host.dart';

/// The exception that is thrown upon [Host] abortion.
class HostAbortedException extends ExceptionBase {
  /// Initializes a new instance of the [HostAbortedException] class
  /// with a system-supplied error message.
  HostAbortedException({
    super.message = 'The host was aborted.',
    super.innerException,
    super.stackTrace,
  });
}
