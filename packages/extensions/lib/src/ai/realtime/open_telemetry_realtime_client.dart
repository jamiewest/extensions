import '../../system/threading/cancellation_token.dart';
import 'delegating_realtime_client.dart';
import 'open_telemetry_realtime_client_session.dart';
import 'realtime_client_session.dart';
import 'realtime_session_options.dart';

/// A delegating real-time client that records OpenTelemetry spans.
///
/// Sessions created by this client are wrapped in an
/// [OpenTelemetryRealtimeClientSession] so their interactions are
/// recorded too.
///
/// This is an experimental feature.
class OpenTelemetryRealtimeClient extends DelegatingRealtimeClient {
  /// Creates a new [OpenTelemetryRealtimeClient].
  OpenTelemetryRealtimeClient(
    super.innerClient, {
    this.modelId,
    this.system,
    this.enableSensitiveData,
  });

  /// The model ID to record on spans (overrides the session model).
  final String? modelId;

  /// The AI system name (e.g. `"openai"`).
  final String? system;

  /// Whether potentially sensitive information (such as message
  /// content) is recorded on spans. When `null`, sessions default to
  /// `TelemetryHelpers.enableSensitiveDataDefault`.
  final bool? enableSensitiveData;

  @override
  Future<RealtimeClientSession> createSession({
    RealtimeSessionOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    final innerSession = await super.createSession(
      options: options,
      cancellationToken: cancellationToken,
    );
    return OpenTelemetryRealtimeClientSession(
      innerSession,
      modelId: modelId,
      system: system,
      enableSensitiveData: enableSensitiveData,
    );
  }
}
