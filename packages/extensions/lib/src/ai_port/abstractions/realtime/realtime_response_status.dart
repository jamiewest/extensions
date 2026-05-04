/// Defines well-known status values for real-time response lifecycle
/// messages.
///
/// Remarks: These constants represent the standard status values that may
/// appear on [Status] when the response completes (i.e., on [ResponseDone]).
/// Providers may use additional status values beyond those defined here.
class RealtimeResponseStatus {
  RealtimeResponseStatus();

  /// Gets the status value indicating the response completed successfully.
  static final String completed = "completed";

  /// Gets the status value indicating the response was cancelled, typically due
  /// to an interruption such as user barge-in (the user started speaking while
  /// the model was generating output).
  static final String cancelled = "cancelled";

  /// Gets the status value indicating the response ended before completing, for
  /// example because the output reached the maximum token limit.
  static final String incomplete = "incomplete";

  /// Gets the status value indicating the response failed due to an error.
  static final String failed = "failed";
}
