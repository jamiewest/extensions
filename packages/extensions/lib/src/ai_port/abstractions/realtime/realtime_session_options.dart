import '../chat_completion/chat_tool_mode.dart';
import '../speech_to_text/transcription_options.dart';
import '../tools/ai_tool.dart';
import 'realtime_audio_format.dart';
import 'realtime_client_session.dart';
import 'realtime_session_kind.dart';
import 'session_update_realtime_client_message.dart';
import 'voice_activity_detection_options.dart';

/// Represents options for configuring a real-time session.
class RealtimeSessionOptions {
  RealtimeSessionOptions();

  /// Gets the session kind.
  ///
  /// Remarks: If set to [Transcription], most of the sessions properties will
  /// not apply to the session. Only InputAudioFormat and TranscriptionOptions
  /// will be used.
  RealtimeSessionKind sessionKind = RealtimeSessionKind.Conversation;

  /// Gets the model name to use for the session.
  String? model;

  /// Gets the input audio format for the session.
  RealtimeAudioFormat? inputAudioFormat;

  /// Gets the transcription options for the session.
  TranscriptionOptions? transcriptionOptions;

  /// Gets the output audio format for the session.
  RealtimeAudioFormat? outputAudioFormat;

  /// Gets the output voice for the session.
  String? voice;

  /// Gets the default system instructions for the session.
  String? instructions;

  /// Gets the maximum number of response tokens for the session.
  int? maxOutputTokens;

  /// Gets the output modalities for the response. like "text", "audio". If
  /// null, then default conversation modalities will be used.
  List<String>? outputModalities;

  /// Gets the tool choice mode for the session.
  ChatToolMode? toolMode;

  /// Gets the AI tools available for generating the response.
  List<ATool>? tools;

  /// Gets the voice activity detection (VAD) options for the session.
  ///
  /// Remarks: When set, configures how the server detects user speech to manage
  /// turn-taking. When `null`, the provider's default VAD behavior is used.
  VoiceActivityDetectionOptions? voiceActivityDetection;

  /// Gets a callback responsible for creating the raw representation of the
  /// session options from an underlying implementation.
  ///
  /// Remarks: The underlying [RealtimeClientSession] implementation might have
  /// its own representation of options. When a
  /// [SessionUpdateRealtimeClientMessage] is sent with a
  /// [RealtimeSessionOptions], that implementation might convert the provided
  /// options into its own representation in order to use it while performing
  /// the operation. For situations where a consumer knows which concrete
  /// [RealtimeClientSession] is being used and how it represents options, a new
  /// instance of that implementation-specific options type can be returned by
  /// this callback for the [RealtimeClientSession] implementation to use,
  /// instead of creating a new instance. Such implementations might mutate the
  /// supplied options instance further based on other settings supplied on this
  /// [RealtimeSessionOptions] instance or from other inputs. Therefore, it is
  /// strongly recommended to not return shared instances and instead make the
  /// callback return a new instance on each call. This is typically used to set
  /// an implementation-specific setting that isn't otherwise exposed from the
  /// strongly typed properties on [RealtimeSessionOptions]. Unlike similar
  /// factories on other options types, this callback does not receive the
  /// session instance as a parameter because some providers need to evaluate it
  /// before the session is created (e.g., to produce connection configuration).
  Object? Function()? rawRepresentationFactory;
}
