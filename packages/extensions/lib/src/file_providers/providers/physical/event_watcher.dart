/// Abstracts platform filesystem event watching for physical file providers.
///
/// Event-based watching relies on `dart:io` (via `package:watcher`) and is only
/// available on VM/native targets. On web, no implementation is available and
/// providers fall back to polling.
abstract interface class EventWatcher {
  /// A broadcast stream that emits an event whenever a path under the watched
  /// root changes.
  ///
  /// Each emitted value is the absolute path that changed.
  Stream<String> get events;

  /// Releases any resources held by the watcher.
  void dispose();
}
