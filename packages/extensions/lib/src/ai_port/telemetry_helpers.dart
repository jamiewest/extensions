/// Provides internal helpers for implementing telemetry.
class TelemetryHelpers {
  TelemetryHelpers();

  /// Gets a value indicating whether the OpenTelemetry clients should enable
  /// their EnableSensitiveData property's by default.
  ///
  /// Remarks: Defaults to false. May be overridden by setting the
  /// OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT environment variable to
  /// "true".
  static final bool enableSensitiveDataDefault;

  /// Serializes `value` as JSON for logging purposes.
  static String asJson<T>(T value, JsonSerializerOptions? options, ) {
    var typeInfo;
    if (options?.tryGetTypeInfo(typeof(T)) is true ||
            AIJsonUtilities.defaultOptions.tryGetTypeInfo(typeof(T), out typeInfo)) {
      try {
        return JsonSerializer.serialize(value, typeInfo);
      } catch (e, s) {
        {}
      }
    }
    return "{}";
  }
}
