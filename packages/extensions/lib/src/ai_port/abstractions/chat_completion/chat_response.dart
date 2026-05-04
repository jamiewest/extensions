import '../contents/usage_content.dart';
import '../response_continuation_token.dart';
import '../usage_details.dart';
import 'chat_client.dart';
import 'chat_finish_reason.dart';
import 'chat_message.dart';
import 'chat_response_update.dart';

/// Represents the response to a chat request.
///
/// Remarks: [ChatResponse] provides one or more response messages and
/// metadata about the response. A typical response will contain a single
/// message, however a response might contain multiple messages in a variety
/// of scenarios. For example, if automatic function calling is employed, such
/// that a single request to a [ChatClient] might actually generate multiple
/// round-trips to an inner [ChatClient] it uses, all of the involved messages
/// might be surfaced as part of the final [ChatResponse].
class ChatResponse {
  /// Initializes a new instance of the [ChatResponse] class.
  ///
  /// [messages] The response messages.
  ChatResponse({ChatMessage? message = null, List<ChatMessage>? messages = null, }) : _messages = messages;

  /// The response messages.
  List<ChatMessage>? _messages;

  /// Gets or sets the chat response messages.
  List<ChatMessage> messages;

  /// Gets or sets the ID of the chat response.
  String? responseId;

  /// Gets or sets an identifier for the state of the conversation.
  ///
  /// Remarks: Some [ChatClient] implementations are capable of storing the
  /// state for a conversation, such that the input messages supplied to
  /// [CancellationToken)] need only be the additional messages beyond what's
  /// already stored. If this property is non-`null`, it represents an
  /// identifier for that state, and it should be used in a subsequent
  /// [ConversationId] instead of supplying the same messages (and this
  /// [ChatResponse]'s message) as part of the `messages` parameter. Note that
  /// the value might differ on every response, depending on whether the
  /// underlying provider uses a fixed ID for each conversation or updates it
  /// for each message.
  String? conversationId;

  /// Gets or sets the model ID used in the creation of the chat response.
  String? modelId;

  /// Gets or sets a timestamp for the chat response.
  DateTime? createdAt;

  /// Gets or sets the reason for the chat response.
  ChatFinishReason? finishReason;

  /// Gets or sets usage details for the chat response.
  UsageDetails? usage;

  /// Gets or sets the continuation token for getting result of the background
  /// chat response.
  ///
  /// Remarks: [ChatClient] implementations that support background responses
  /// will return a continuation token if background responses are allowed in
  /// [AllowBackgroundResponses] and the result of the response has not been
  /// obtained yet. If the response has completed and the result has been
  /// obtained, the token will be `null`. This property should be used in
  /// conjunction with [ContinuationToken] to continue to poll for the
  /// completion of the response. Pass this token to [ContinuationToken] on
  /// subsequent calls to [CancellationToken)] to poll for completion.
  ResponseContinuationToken? continuationToken;

  ResponseContinuationToken? continuationTokenCore;

  /// Gets or sets the raw representation of the chat response from an
  /// underlying implementation.
  ///
  /// Remarks: If a [ChatResponse] is created to represent some underlying
  /// object from another object model, this property can be used to store that
  /// original object. This can be useful for debugging or for enabling a
  /// consumer to access the underlying object model if needed.
  Object? rawRepresentation;

  /// Gets or sets any additional properties associated with the chat response.
  AdditionalPropertiesDictionary? additionalProperties;

  /// Gets the text of the response.
  ///
  /// Remarks: This property concatenates the [Text] of all [ChatMessage]
  /// instances in [Messages].
  String get text {
    return _messages?.concatText() ?? string.empty;
  }

  @override
  String toString() {
    return text;
  }

  /// Creates an array of [ChatResponseUpdate] instances that represent this
  /// [ChatResponse].
  ///
  /// Returns: An array of [ChatResponseUpdate] instances that can be used to
  /// represent this [ChatResponse].
  List<ChatResponseUpdate> toChatResponseUpdates() {
    var extra = null;
    if (additionalProperties != null|| usage != null) {
      extra = chatResponseUpdate();
      if (usage is { } usage) {
        extra.contents.add(usageContent(usage));
      }
    }
    var messageCount = _messages?.count ?? 0;
    var updates = List.filled(messageCount + (extra != null ? 1 : 0), null);
    int i;
    for (i = 0; i < messageCount; i++) {
      var message = _messages![i];
      updates[i] = chatResponseUpdate();
    }
    if (extra != null) {
      updates[i] = extra;
    }
    return updates;
  }
}
