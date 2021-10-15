import 'cancellation_token.dart';

class OperationCanceledException implements Exception {
  OperationCanceledException(
    this.message,
    this.cancellationToken,
  );

  /// Gets a token associated with the operation that was canceled.
  final CancellationToken cancellationToken;

  /// Gets a message that describes the current exception.
  final String message;
}
