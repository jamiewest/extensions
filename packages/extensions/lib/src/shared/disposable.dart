/// Provides a mechanism for releasing unmanaged resources.
abstract class Disposable {
  const Disposable();

  /// Performs application-defined tasks associated with freeing, releasing,
  /// or resetting unmanaged resources.
  void dispose();
}
