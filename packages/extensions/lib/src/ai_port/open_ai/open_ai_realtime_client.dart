import '../abstractions/chat_completion/chat_client_metadata.dart';
import '../abstractions/realtime/realtime_client.dart';
import '../abstractions/realtime/realtime_client_session.dart';
import '../abstractions/realtime/realtime_session_kind.dart';
import '../abstractions/realtime/realtime_session_options.dart';
import '../abstractions/realtime/session_update_realtime_client_message.dart';
import 'open_ai_realtime_client_session.dart';

/// Represents an [RealtimeClient] for the OpenAI Realtime API.
class OpenARealtimeClient implements RealtimeClient {
  /// Initializes a new instance of the [OpenAIRealtimeClient] class.
  ///
  /// [apiKey] The API key used for authentication.
  ///
  /// [model] The model to use for realtime sessions.
  OpenARealtimeClient(
    String model,
    {String? apiKey = null, RealtimeClient? realtimeClient = null, },
  ) :
      _realtimeClient = realtimeClient(Throw.ifNull(apiKey)),
      _model = Throw.ifNull(model),
      _metadata = new("openai", defaultModelId: _model);

  /// The OpenAI Realtime client.
  final RealtimeClient _realtimeClient;

  /// The model to use for realtime sessions.
  final String _model;

  /// Metadata about this client's provider and model, used for OpenTelemetry.
  final ChatClientMetadata _metadata;

  @override
  Future<RealtimeClientSession> createSession({RealtimeSessionOptions? options, CancellationToken? cancellationToken, }) async  {
    var sessionClient = options?.sessionKind == RealtimeSessionKind.transcription
            ? await _realtimeClient.startTranscriptionSessionAsync(cancellationToken: cancellationToken).configureAwait(false)
            : await _realtimeClient.startConversationSessionAsync(
              _model,
              cancellationToken: cancellationToken,
            ) .configureAwait(false);
    var session = openARealtimeClientSession(sessionClient, _model);
    try {
      if (options != null) {
        await session.sendAsync(
          sessionUpdateRealtimeClientMessage(options),
          cancellationToken,
        ) .configureAwait(false);
      }
      return session;
    } catch (e, s) {
      {
        await session.disposeAsync().configureAwait(false);
        rethrow;
      }
    }
  }

  Object? getService(Type serviceType, Object? serviceKey, ) {
    _ = Throw.ifNull(serviceType);
    return serviceKey != null ? null :
            serviceType == typeof(ChatClientMetadata) ? _metadata :
            serviceType.isInstanceOfType(this) ? this :
            serviceType.isInstanceOfType(_realtimeClient) ? _realtimeClient :
            null;
  }

  @override
  void dispose() {

  }
}
