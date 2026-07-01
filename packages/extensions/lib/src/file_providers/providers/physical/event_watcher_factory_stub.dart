import 'event_watcher.dart';

/// Event-based watching is unavailable on this platform.
///
/// Returns `null` so callers fall back to polling.
EventWatcher? createEventWatcher(String root) => null;
