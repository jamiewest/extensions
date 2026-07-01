import 'dart:async';

import 'package:stream_transform/stream_transform.dart';
import 'package:watcher/watcher.dart';

import 'event_watcher.dart';

/// Creates a `package:watcher` backed [EventWatcher] for [root].
///
/// Returns `null` if a watcher cannot be created for the given root.
EventWatcher? createEventWatcher(String root) {
  try {
    return _WatcherEventWatcher(root);
  } catch (_) {
    return null;
  }
}

class _WatcherEventWatcher implements EventWatcher {
  final Watcher _watcher;
  final StreamController<String> _controller =
      StreamController<String>.broadcast();
  StreamSubscription<WatchEvent>? _subscription;

  _WatcherEventWatcher(String root) : _watcher = Watcher(root) {
    _subscription = _watcher.events
        .debounce(const Duration(milliseconds: 200))
        .listen((event) => _controller.add(event.path));
  }

  @override
  Stream<String> get events => _controller.stream;

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
