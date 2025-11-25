/// Provides a mechanism for releasing unmanaged resources.
abstract interface class IDisposable {
  /// Performs application-defined tasks associated with freeing, releasing,
  /// or resetting unmanaged resources.
  void dispose();
}

/// Alias for [IDisposable] for backwards compatibility.
typedef Disposable = IDisposable;
