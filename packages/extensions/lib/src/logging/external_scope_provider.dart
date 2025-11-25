import '../system/disposable.dart';

typedef ScopeCallback<TState> = void Function(
  Object? object,
  TState state,
);

/// Represents a storage of common scope data.
abstract class ExternalScopeProvider {
  /// Executes callback for each currently active scope objects in order
  /// of creation. All callbacks are guaranteed to be called inline from
  /// this method.
  void forEachScope<TState>(
    ScopeCallback<TState> callback,
    TState state,
  );

  /// Adds scope object to the list
  Disposable push(Object? state);
}
