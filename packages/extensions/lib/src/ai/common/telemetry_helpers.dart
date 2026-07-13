import 'dart:convert';

import 'package:extensions/annotations.dart';

/// Provides internal helpers for implementing telemetry.
///
/// Not exported from the `ai` barrel; this mirrors the C# `internal`
/// type.
@Source(
  name: 'TelemetryHelpers.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI/',
)
abstract final class TelemetryHelpers {
  /// Whether the OpenTelemetry clients enable their
  /// `enableSensitiveData` property by default.
  ///
  /// Defaults to `false`. Upstream reads the
  /// `OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT` environment
  /// variable; reading the environment requires `dart:io`, which would
  /// break web support, so hosts should set this explicitly during
  /// bootstrap instead (for example from configuration).
  static bool enableSensitiveDataDefault = false;

  /// Serializes [value] as JSON for logging purposes.
  ///
  /// Returns `"{}"` when the value cannot be serialized; lack of
  /// serializability must never disrupt application behavior with
  /// exceptions.
  static String asJson(Object? value) {
    try {
      return jsonEncode(value, toEncodable: (v) => v.toString());
    } catch (_) {
      return '{}';
    }
  }
}
