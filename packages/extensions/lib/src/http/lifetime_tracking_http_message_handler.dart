import 'package:http/http.dart' as http;

import 'delegating_handler.dart';
import 'http_message_handler.dart';

/// A delegating handler that tracks the lifetime of HTTP message handlers
/// and prevents premature disposal.
///
/// This handler wraps another handler and overrides the dispose method to
/// prevent it from being disposed until the factory determines it's safe to do
/// so (after the configured lifetime expires and there are no active
/// requests).
class LifetimeTrackingHttpMessageHandler extends DelegatingHandler {
  /// Creates a new [LifetimeTrackingHttpMessageHandler].
  LifetimeTrackingHttpMessageHandler(HttpMessageHandler super.innerHandler);

  int _activeRequests = 0;

  /// The number of requests currently in flight through this handler.
  ///
  /// A request is counted from `send` until its [http.StreamedResponse]
  /// future completes; consumption of the response body stream is not
  /// tracked.
  int get activeRequests => _activeRequests;

  /// Whether any requests are currently in flight.
  bool get hasActiveRequests => _activeRequests > 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    _activeRequests++;
    final Future<http.StreamedResponse> result;
    try {
      result = super.send(request);
    } catch (_) {
      _activeRequests--;
      rethrow;
    }
    return result.whenComplete(() => _activeRequests--);
  }

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
