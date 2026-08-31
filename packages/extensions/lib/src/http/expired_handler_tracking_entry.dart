import 'active_handler_tracking_entry.dart';
import 'lifetime_tracking_http_message_handler.dart';

/// Tracks a rotated-out handler until it can be disposed safely.
///
/// Upstream uses a weak reference plus finalizer to detect that no
/// outstanding requests reference the handler; the Dart port instead
/// counts in-flight requests on [LifetimeTrackingHttpMessageHandler]
/// and disposes once none remain, which also works on the web.
///
/// Not exported from the `http` barrel; this mirrors the C# `internal`
/// type.
class ExpiredHandlerTrackingEntry {
  /// Creates a new [ExpiredHandlerTrackingEntry] from the active entry
  /// being rotated out.
  ExpiredHandlerTrackingEntry(ActiveHandlerTrackingEntry other)
    : name = other.name,
      _handler = other.handler;

  /// The logical client name the handler served.
  final String name;

  final LifetimeTrackingHttpMessageHandler _handler;

  /// Whether the handler has no in-flight requests and can be
  /// disposed.
  bool get canDispose => !_handler.hasActiveRequests;

  /// Disposes the tracked handler pipeline.
  void disposeInner() => _handler.disposeInner();
}
