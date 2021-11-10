/// Provides a mechanism for releasing unmanaged resources asynchronously.
abstract class AsyncDisposable {
  /// Performs application-defined tasks associated with freeing, releasing,
  /// or resetting unmanaged resources asynchronously.
  Future<void> disposeAsync();
}
