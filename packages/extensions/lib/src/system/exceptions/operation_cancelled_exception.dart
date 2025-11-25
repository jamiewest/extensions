import '../threading/cancellation_token.dart';
import 'system_exception.dart';

/// The exception that is thrown in a thread upon cancellation of
/// an operation that the thread was executing.
class OperationCanceledException extends SystemException {
  OperationCanceledException({
    super.message = 'The operation was canceled.',
    super.innerException,
    super.stackTrace,
    this.cancellationToken,
  });

  /// Gets a token associated with the operation that was canceled.
  final CancellationToken? cancellationToken;
}
