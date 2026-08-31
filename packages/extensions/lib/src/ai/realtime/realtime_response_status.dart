/// Provides the well-known status values for a real-time response.
///
/// This is an experimental feature.
abstract final class RealtimeResponseStatus {
  /// The response completed successfully.
  static const String completed = 'completed';

  /// The response was cancelled.
  static const String cancelled = 'cancelled';

  /// The response is incomplete.
  static const String incomplete = 'incomplete';

  /// The response failed.
  static const String failed = 'failed';
}
