import 'package:async/async.dart';

import 'cancellation_token.dart';

/// Provides support for creating [Future] objects.
extension FutureExtensions<T> on Future<T> {
  Future<T> toCancelableFuture([CancellationToken? token]) {
    var operation = CancelableOperation<T>.fromFuture(this);

    if (token != null) {
      token.register(
        (state) => (state as CancelableOperation).cancel(),
        operation,
      );
    }

    return operation.value;
  }
}
