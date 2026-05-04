import 'realtime_conversation_item.dart';
import 'realtime_server_message.dart';
import 'realtime_server_message_type.dart';

/// Represents a real-time message representing a new output item added or
/// created during response generation.
///
/// Remarks: Used with the [ResponseOutputItemDone] and
/// [ResponseOutputItemAdded] messages. Provider implementations should emit
/// this message with [ResponseOutputItemDone] when an output item (such as a
/// function call or text message) has completed. The built-in
/// `FunctionInvokingRealtimeClientSession` middleware depends on this message
/// to detect and invoke tool calls.
class ResponseOutputItemRealtimeServerMessage extends RealtimeServerMessage {
  /// Initializes a new instance of the
  /// [ResponseOutputItemRealtimeServerMessage] class.
  ///
  /// Remarks: The `type` should be [ResponseOutputItemDone] or
  /// [ResponseOutputItemAdded].
  ResponseOutputItemRealtimeServerMessage(RealtimeServerMessageType type) {
    Type = type;
  }

  /// Gets or sets the unique response ID.
  ///
  /// Remarks: May be `null` for providers that do not natively track response
  /// lifecycle.
  String? responseId;

  /// Gets or sets the unique output index.
  int? outputIndex;

  /// Gets or sets the conversation item included in the response.
  RealtimeConversationItem? item;
}
