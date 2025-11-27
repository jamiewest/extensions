import 'delegating_handler.dart';
import 'http_message_handler.dart';

/// A delegating handler that tracks the lifetime of HTTP message handlers
/// and prevents premature disposal.
///
/// This handler wraps another handler and overrides the dispose method to
/// prevent it from being disposed until the factory determines it's safe to do
/// so (after the configured lifetime expires and there are no active requests).
class LifetimeTrackingHttpMessageHandler extends DelegatingHandler {
  /// Creates a new [LifetimeTrackingHttpMessageHandler].
  LifetimeTrackingHttpMessageHandler(HttpMessageHandler innerHandler)
      : super(innerHandler);

  @override
  void dispose() {
    // Don't dispose the inner handler here.
    // The factory will manage disposal based on lifetime tracking.
    // This prevents premature disposal while requests are still in flight.
  }

  /// Disposes the inner handler.
  ///
  /// This method is called by the factory when it's safe to dispose the
  /// handler (after the lifetime expires and no active requests remain).
  void disposeInner() {
    super.dispose();
  }
}
