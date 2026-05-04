import '../chat_completion/chat_tool_mode.dart';
import '../tools/ai_tool.dart';
import 'realtime_audio_format.dart';
import 'realtime_client_message.dart';
import 'realtime_conversation_item.dart';

/// Represents a client message that triggers model inference to generate a
/// response.
///
/// Remarks: Sending this message instructs the provider to generate a new
/// response from the model. The response may include one or more output items
/// (text, audio, or tool calls). Properties on this message optionally
/// override the session-level configuration for this response only. Not all
/// providers support explicit response triggering. Voice-activity-detection
/// (VAD) driven providers may respond automatically when speech is detected
/// or input is committed, in which case this message may be treated as a
/// no-op. Per-response overrides (instructions, tools, voice, etc.) are
/// advisory and may be silently ignored by providers that do not support
/// them.
class CreateResponseRealtimeClientMessage extends RealtimeClientMessage {
  /// Initializes a new instance of the [CreateResponseRealtimeClientMessage]
  /// class.
  const CreateResponseRealtimeClientMessage();

  /// Gets or sets the list of the conversation items to create a response for.
  List<RealtimeConversationItem>? items;

  /// Gets or sets the output audio options for the response.
  ///
  /// Remarks: If set, overrides the session-level audio output configuration
  /// for this response only. If `null`, the session's default audio options are
  /// used.
  RealtimeAudioFormat? outputAudioOptions;

  /// Gets or sets the voice of the output audio.
  ///
  /// Remarks: If set, overrides the session-level voice for this response only.
  /// If `null`, the session's default voice is used.
  String? outputVoice;

  /// Gets or sets a value indicating whether the response output should be
  /// excluded from the conversation context.
  ///
  /// Remarks: When `true`, the response is generated out-of-band: the model
  /// produces output but the resulting items are not added to the conversation
  /// history, so they will not appear as context for subsequent responses. If
  /// `null`, the provider's default behavior is used.
  bool? excludeFromConversation;

  /// Gets or sets the instructions that guide the model on desired responses.
  ///
  /// Remarks: If set, overrides the session-level instructions for this
  /// response only. If `null`, the session's default instructions are used.
  String? instructions;

  /// Gets or sets the maximum number of output tokens for the response,
  /// inclusive of all modalities and tool calls.
  ///
  /// Remarks: This limit applies to the total output tokens regardless of
  /// modality (text, audio, etc.). If `null`, the provider's default limit is
  /// used.
  int? maxOutputTokens;

  /// Gets or sets any additional properties associated with the response
  /// request.
  ///
  /// Remarks: This can be used to attach arbitrary key-value metadata to a
  /// response request for tracking or disambiguation purposes (e.g.,
  /// correlating multiple simultaneous responses). Providers may map this to
  /// their own metadata fields.
  AdditionalPropertiesDictionary? additionalProperties;

  /// Gets or sets the output modalities for the response (e.g., "text",
  /// "audio").
  ///
  /// Remarks: If set, overrides the session-level output modalities for this
  /// response only. If `null`, the session's default modalities are used.
  List<String>? outputModalities;

  /// Gets or sets the tool choice mode for the response.
  ///
  /// Remarks: If set, overrides the session-level tool choice for this response
  /// only. If `null`, the session's default tool choice is used.
  ChatToolMode? toolMode;

  /// Gets or sets the AI tools available for generating the response.
  ///
  /// Remarks: If set, overrides the session-level tools for this response only.
  /// If `null`, the session's default tools are used.
  List<ATool>? tools;
}
