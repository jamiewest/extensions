import 'eviction_reason.dart';

/// Signature for callbacks that are called when a cache entry is evicted.
///
/// Parameters:
/// - [key]: The key of the evicted cache entry.
/// - [value]: The value of the evicted cache entry.
/// - [reason]: The reason why the entry was evicted.
/// - [state]: Optional state that was provided when registering the callback.
typedef PostEvictionDelegate = void Function(
  Object key,
  Object? value,
  EvictionReason reason,
  Object? state,
);

/// Registration for a callback that should be called when a cache entry is evicted.
class PostEvictionCallbackRegistration {
  /// Creates a new instance of [PostEvictionCallbackRegistration].
  PostEvictionCallbackRegistration({
    required this.evictionCallback,
    this.state,
  });

  /// Gets the callback to call after an entry is evicted.
  final PostEvictionDelegate evictionCallback;

  /// Gets the state to pass to the [evictionCallback].
  final Object? state;
}
