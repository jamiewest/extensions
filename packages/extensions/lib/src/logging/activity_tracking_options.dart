/// Flags to indicate which trace context parts should be included
/// with the logging scopes.
class ActivityTrackingOptions {
  /// None of the trace context part wil be included in the logging.
  static const none = 0x0000;

  /// Span Id will be included in the logging.
  static const spanId = 0x0001;

  /// Trace Id will be included in the logging.
  static const traceId = 0x0002;

  /// Parent Id will be included in the logging.
  static const parentId = 0x0004;

  /// Trace State will be included in the logging.
  static const traceState = 0x0008;

  /// Trace flags will be included in the logging.
  static const traceFlags = 0x0010;

  /// Tags will be included in the logging.
  static const tags = 0x0020;

  /// Items of baggage will be included in the logging.
  static const baggage = 0x0040;
}
