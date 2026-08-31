import 'chat_turn_details.dart';

/// Records details for all LLM chat turns in a [ScenarioRun] execution.
class ChatDetails {
  /// Creates [ChatDetails] with an optional initial list of [turnDetails].
  ChatDetails({List<ChatTurnDetails>? turnDetails})
    : turnDetails = turnDetails ?? [];

  /// Turn-by-turn details recorded during the scenario run.
  List<ChatTurnDetails> turnDetails;

  /// Appends [details] to [turnDetails].
  void addTurnDetails(ChatTurnDetails details) => turnDetails.add(details);
}
