import 'realtime_conversation_item.dart';
import 'realtime_server_message.dart';

/// A server message describing an output item added to or completed within a
/// response.
///
/// This is an experimental feature.
class ResponseOutputItemRealtimeServerMessage extends RealtimeServerMessage {
  /// Creates a new [ResponseOutputItemRealtimeServerMessage] with the given
  /// [type].
  ResponseOutputItemRealtimeServerMessage(super.type);

  /// The ID of the response.
  String? responseId;

  /// The index of the output item.
  int? outputIndex;

  /// The output conversation item.
  RealtimeConversationItem? item;
}
