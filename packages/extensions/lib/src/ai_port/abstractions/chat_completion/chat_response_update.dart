import '../contents/ai_content.dart';
import '../contents/text_content.dart';
import '../response_continuation_token.dart';
import 'chat_client.dart';
import 'chat_finish_reason.dart';
import 'chat_message.dart';
import 'chat_role.dart';

/// Represents a single streaming response chunk from an [ChatClient].
///
/// Remarks: [ChatResponseUpdate] is so named because it represents updates
/// that layer on each other to form a single chat response. Conceptually,
/// this combines the roles of [ChatResponse] and [ChatMessage] in streaming
/// output. The relationship between [ChatResponse] and [ChatResponseUpdate]
/// is codified in the [CancellationToken)] and [ToChatResponseUpdates], which
/// enable bidirectional conversions between the two. Note, however, that the
/// provided conversions might be lossy, for example, if multiple updates all
/// have different [RawRepresentation] objects whereas there's only one slot
/// for such an object available in [RawRepresentation]. Similarly, if
/// different updates provide different values for properties like [ModelId],
/// only one of the values will be used to populate [ModelId].
class ChatResponseUpdate {
  /// Initializes a new instance of the [ChatResponseUpdate] class.
  ///
  /// [role] The role of the author of the update.
  ///
  /// [contents] The contents of the update.
  ChatResponseUpdate({ChatRole? role = null, String? content = null, List<AContent>? contents = null, }) : role = role, _contents = contents;

  /// The response update content items.
  List<AContent>? _contents;

  /// Gets or sets the name of the author of the response update.
  String? authorName;

  /// Gets or sets the role of the author of the response update.
  ChatRole? role;

  /// Gets or sets the chat response update content items.
  List<AContent> contents;

  /// Gets or sets the raw representation of the response update from an
  /// underlying implementation.
  ///
  /// Remarks: If a [ChatResponseUpdate] is created to represent some underlying
  /// object from another object model, this property can be used to store that
  /// original object. This can be useful for debugging or for enabling a
  /// consumer to access the underlying object model if needed.
  Object? rawRepresentation;

  /// Gets or sets additional properties for the update.
  AdditionalPropertiesDictionary? additionalProperties;

  /// Gets or sets the ID of the response of which this update is a part.
  String? responseId;

  /// Gets or sets the ID of the message of which this update is a part.
  ///
  /// Remarks: A single streaming response might be composed of multiple
  /// messages, each of which might be represented by multiple updates. This
  /// property is used to group those updates together into messages. Some
  /// providers might consider streaming responses to be a single message, and
  /// in that case the value of this property might be the same as the response
  /// ID. This value is used when [CancellationToken)] groups
  /// [ChatResponseUpdate] instances into [ChatMessage] instances. The value
  /// must be unique to each call to the underlying provider, and must be shared
  /// by all updates that are part of the same logical message within a
  /// streaming response.
  String? messageId;

  /// Gets or sets an identifier for the state of the conversation of which this
  /// update is a part.
  ///
  /// Remarks: Some [ChatClient] implementations are capable of storing the
  /// state for a conversation, such that the input messages supplied to
  /// [CancellationToken)] need only be the additional messages beyond what's
  /// already stored. If this property is non-`null`, it represents an
  /// identifier for that state, and it should be used in a subsequent
  /// [ConversationId] instead of supplying the same messages (and this
  /// streaming message) as part of the `messages` parameter. Note that the
  /// value might differ on every response, depending on whether the underlying
  /// provider uses a fixed ID for each conversation or updates it for each
  /// message.
  String? conversationId;

  /// Gets or sets a timestamp for the response update.
  DateTime? createdAt;

  /// Gets or sets the finish reason for the operation.
  ChatFinishReason? finishReason;

  /// Gets or sets the model ID associated with this response update.
  String? modelId;

  /// Gets or sets the continuation token for resuming the streamed chat
  /// response of which this update is a part.
  ///
  /// Remarks: [ChatClient] implementations that support background responses
  /// return a continuation token on each update if background responses are
  /// allowed in [AllowBackgroundResponses]. However, for the last update, the
  /// token will be `null`. This property should be used for stream resumption,
  /// where the continuation token of the latest received update should be
  /// passed to [ContinuationToken] on subsequent calls to [CancellationToken)]
  /// to resume streaming from the point of interruption.
  ResponseContinuationToken? continuationToken;

  ResponseContinuationToken? continuationTokenCore;

  /// Gets a [AIContent] object to display in the debugger display.
  final AContent? contentForDebuggerDisplay;

  /// Creates a new ChatResponseUpdate instance that is a copy of the current
  /// object.
  ///
  /// Remarks: The cloned object is a shallow copy; reference-type properties
  /// will reference the same objects as the original. Use this method to
  /// duplicate the response update for further modification without affecting
  /// the original instance.
  ///
  /// Returns: A new ChatResponseUpdate object with the same property values as
  /// the current instance.
  ChatResponseUpdate clone() {
    return new()
        {
            additionalProperties = additionalProperties,
            authorName = authorName,
            contents = contents,
            createdAt = createdAt,
            conversationId = conversationId,
            finishReason = finishReason,
            messageId = messageId,
            modelId = modelId,
            rawRepresentation = rawRepresentation,
            responseId = responseId,
            role = role,
        };
  }

  /// Gets the text of this update.
  ///
  /// Remarks: This property concatenates the text of all [TextContent] objects
  /// in [Contents].
  String get text {
    return _contents != null ? _contents.concatText() : string.empty;
  }

  @override
  String toString() {
    return text;
  }

  /// Gets an indication for the debugger display of whether there's more
  /// content.
  String get ellipsesForDebuggerDisplay {
    return _contents is { Count: > 1 } ? ", ..." : string.empty;
  }
}
