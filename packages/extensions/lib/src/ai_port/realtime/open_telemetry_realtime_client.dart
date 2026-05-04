import '../abstractions/realtime/delegating_realtime_client.dart';
import '../abstractions/realtime/realtime_client.dart';
import '../abstractions/realtime/realtime_client_session.dart';
import '../abstractions/realtime/realtime_session_options.dart';
import 'open_telemetry_realtime_client_session.dart';

/// A delegating realtime client that adds OpenTelemetry support, following
/// the OpenTelemetry Semantic Conventions for Generative AI systems.
///
/// Remarks: The draft specification this follows is available at . The
/// specification is still experimental and subject to change; as such, the
/// telemetry output by this client is also subject to change.
class OpenTelemetryRealtimeClient extends DelegatingRealtimeClient {
  /// Initializes a new instance of the [OpenTelemetryRealtimeClient] class.
  ///
  /// [innerClient] The inner [RealtimeClient].
  ///
  /// [logger] The [Logger] to use for emitting any logging data from the
  /// client.
  ///
  /// [sourceName] An optional source name that will be used on the telemetry
  /// data.
  OpenTelemetryRealtimeClient(
    RealtimeClient innerClient, {
    Logger? logger = null,
    String? sourceName = null,
  }) : _logger = logger,
       _sourceName = sourceName,
       _jsonSerializerOptions = AIJsonUtilities.defaultOptions;

  final Logger? _logger;

  final String? _sourceName;

  JsonSerializerOptions _jsonSerializerOptions;

  /// Gets or sets a value indicating whether potentially sensitive information
  /// should be included in telemetry.
  bool enableSensitiveData = TelemetryHelpers.EnableSensitiveDataDefault;

  /// Gets or sets JSON serialization options to use when formatting realtime
  /// data into telemetry strings.
  JsonSerializerOptions jsonSerializerOptions;

  @override
  Future<RealtimeClientSession> createSession({
    RealtimeSessionOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    var innerSession = await base
        .createSessionAsync(options, cancellationToken)
        .configureAwait(false);
    return openTelemetryRealtimeClientSession(
      innerSession,
      _logger,
      _sourceName,
    );
  }
}
