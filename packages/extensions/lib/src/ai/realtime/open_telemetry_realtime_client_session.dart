import 'dart:developer' as developer;

import 'package:extensions/annotations.dart';

import '../../system/threading/cancellation_token.dart';
import '../common/telemetry_helpers.dart';
import '../open_telemetry_consts.dart';
import 'realtime_client_message.dart';
import 'realtime_client_session.dart';
import 'realtime_server_message.dart';
import 'realtime_session_options.dart';

/// A [RealtimeClientSession] that records OpenTelemetry spans.
///
/// This implementation uses `dart:developer` timeline events. To
/// connect it to a real OpenTelemetry SDK, subclass and wrap [send]
/// and [getStreamingResponse].
///
/// This is an experimental feature.
@Source(
  name: 'OpenTelemetryRealtimeClientSession.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI/Realtime/',
)
class OpenTelemetryRealtimeClientSession implements RealtimeClientSession {
  /// Creates a new [OpenTelemetryRealtimeClientSession] wrapping
  /// [innerSession].
  OpenTelemetryRealtimeClientSession(
    this.innerSession, {
    this.modelId,
    this.system,
    bool? enableSensitiveData,
  }) : enableSensitiveData =
           enableSensitiveData ?? TelemetryHelpers.enableSensitiveDataDefault;

  /// The inner session to delegate to.
  final RealtimeClientSession innerSession;

  /// The model ID to record on spans (overrides the session model).
  final String? modelId;

  /// The AI system name (e.g. `"openai"`).
  final String? system;

  /// Whether potentially sensitive information (such as message
  /// content) is recorded on spans. Defaults to
  /// [TelemetryHelpers.enableSensitiveDataDefault].
  final bool enableSensitiveData;

  @override
  RealtimeSessionOptions? get options => innerSession.options;

  @override
  Future<void> send(
    RealtimeClientMessage message, {
    CancellationToken? cancellationToken,
  }) async {
    developer.Timeline.startSync(
      '${OpenTelemetryConsts.realtimeSpanName}.send',
      arguments: {
        ..._buildArguments(),
        if (enableSensitiveData && message.rawRepresentation != null)
          OpenTelemetryConsts.inputMessagesKey: TelemetryHelpers.asJson(
            message.rawRepresentation,
          ),
      },
    );
    try {
      await innerSession.send(message, cancellationToken: cancellationToken);
      developer.Timeline.finishSync();
    } catch (e) {
      developer.Timeline.finishSync();
      rethrow;
    }
  }

  @override
  Stream<RealtimeServerMessage> getStreamingResponse({
    CancellationToken? cancellationToken,
  }) async* {
    developer.Timeline.startSync(
      '${OpenTelemetryConsts.realtimeSpanName}.streaming',
      arguments: _buildArguments(),
    );
    try {
      yield* innerSession.getStreamingResponse(
        cancellationToken: cancellationToken,
      );
      developer.Timeline.finishSync();
    } catch (e) {
      developer.Timeline.finishSync();
      rethrow;
    }
  }

  @override
  T? getService<T>({Object? key}) => innerSession.getService<T>(key: key);

  @override
  Future<void> disposeAsync() => innerSession.disposeAsync();

  Map<String, Object?> _buildArguments() {
    final sessionOptions = options;
    return {
      if (system != null) OpenTelemetryConsts.systemKey: system,
      OpenTelemetryConsts.requestModelKey:
          sessionOptions?.model ?? modelId ?? 'unknown',
      OpenTelemetryConsts.sessionKindKey: sessionOptions?.sessionKind.value,
      if (sessionOptions?.voice != null)
        OpenTelemetryConsts.voiceKey: sessionOptions?.voice,
      if (sessionOptions?.outputModalities != null)
        OpenTelemetryConsts.outputModalitiesKey: sessionOptions
            ?.outputModalities
            ?.join(','),
    };
  }
}
