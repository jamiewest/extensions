/// Resolves the platform [EventWatcher] factory.
///
/// On VM/native targets this exposes a `package:watcher` backed implementation;
/// on web it exposes a stub that always returns `null`.
library;

export 'event_watcher_factory_stub.dart'
    if (dart.library.io) 'event_watcher_factory_io.dart';
