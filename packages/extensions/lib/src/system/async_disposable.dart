/// Provides a mechanism for releasing unmanaged resources asynchronously.
abstract class IAsyncDisposable {
  /// Performs application-defined tasks associated with freeing, releasing,
  /// or resetting unmanaged resources asynchronously.
  Future<void> disposeAsync();
}

/// Alias for [IAsyncDisposable] for backwards compatibility.
typedef AsyncDisposable = IAsyncDisposable;
