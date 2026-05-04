import '../contents/error_content.dart';
import '../usage_details.dart';
import 'realtime_audio_format.dart';
import 'realtime_conversation_item.dart';
import 'realtime_response_status.dart';
import 'realtime_server_message.dart';
import 'realtime_server_message_type.dart';

/// Represents a real-time message for creating a response item.
///
/// Remarks: Used with the [ResponseDone] and [ResponseCreated] messages.
/// Provider implementations should emit this message with [ResponseCreated]
/// when the model begins generating a new response, and with [ResponseDone]
/// when the response is complete. The built-in
/// `OpenTelemetryRealtimeClientSession` middleware depends on these messages
/// for tracing response lifecycle. Providers that do not natively support
/// response lifecycle events (e.g., those that only stream content parts and
/// signal turn completion) should synthesize these messages to ensure correct
/// middleware behavior. In such cases, [ResponseId] may be set to a synthetic
/// value or left `null`.
class ResponseCreatedRealtimeServerMessage extends RealtimeServerMessage {
  /// Initializes a new instance of the [ResponseCreatedRealtimeServerMessage]
  /// class.
  ///
  /// Remarks: The `type` should be [ResponseDone] or [ResponseCreated].
  ResponseCreatedRealtimeServerMessage(RealtimeServerMessageType type) {
    Type = type;
  }

  /// Gets or sets the output audio options for the response. If null, the
  /// default conversation audio options will be used.
  RealtimeAudioFormat? outputAudioOptions;

  /// Gets or sets the voice of the output audio.
  String? outputVoice;

  /// Gets or sets the unique response ID.
  ///
  /// Remarks: Some providers (e.g., OpenAI) assign a unique ID to each
  /// response. Providers that do not natively track response lifecycles may set
  /// this to `null` or generate a synthetic ID. Consumers should not assume
  /// this value correlates to a provider-specific concept.
  String? responseId;

  /// Gets or sets the maximum number of output tokens for the response,
  /// inclusive of all modalities and tool calls.
  ///
  /// Remarks: This limit applies to the total output tokens regardless of
  /// modality (text, audio, etc.). If `null`, the provider's default limit was
  /// used.
  int? maxOutputTokens;

  /// Gets or sets any additional properties associated with the response.
  ///
  /// Remarks: Contains arbitrary key-value metadata attached to the response.
  /// This is the metadata that was provided when the response was created
  /// (e.g., for tracking or disambiguating multiple simultaneous responses).
  AdditionalPropertiesDictionary? additionalProperties;

  /// Gets or sets the list of the conversation items included in the response.
  List<RealtimeConversationItem>? items;

  /// Gets or sets the output modalities for the response. like "text", "audio".
  /// If null, then default conversation modalities will be used.
  List<String>? outputModalities;

  /// Gets or sets the status of the response.
  ///
  /// Remarks: Typically set on [ResponseDone] messages to indicate how the
  /// response ended. See [RealtimeResponseStatus] for well-known values such as
  /// [Completed], [Cancelled] (e.g., due to user barge-in), [Incomplete], and
  /// [Failed].
  String? status;

  /// Gets or sets the error content of the response, if any.
  ErrorContent? error;

  /// Gets or sets the per-response token usage for billing purposes.
  ///
  /// Remarks: Populated when the response is complete (i.e., on
  /// [ResponseDone]). Input tokens include the entire conversation context, so
  /// they grow over successive turns as previous output becomes input for later
  /// responses.
  UsageDetails? usage;
}
