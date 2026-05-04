import 'chat_details.dart';
import 'chat_turn_details.dart';

/// Extension methods for [ChatDetails].
extension ChatDetailsExtensions on ChatDetails {
  /// Adds [ChatTurnDetails] for one or more LLM chat conversation turns to the
  /// [TurnDetails] collection.
  ///
  /// [chatDetails] The [ChatDetails] object to which the `turnDetails` are to
  /// be added.
  ///
  /// [turnDetails] The [ChatTurnDetails] for one or more LLM chat conversation
  /// turns.
  void addTurnDetails({Iterable<ChatTurnDetails>? turnDetails}) {
    _ = Throw.ifNull(chatDetails);
    _ = Throw.ifNull(turnDetails);
    for (final t in turnDetails) {
      chatDetails.turnDetails.add(t);
    }
  }
}
