import 'chat_turn_details.dart';
import 'scenario_run.dart';

/// A class that records details related to all LLM chat conversation turns
/// involved in the execution of a particular [ScenarioRun].
class ChatDetails {
  /// Initializes a new instance of the [ChatDetails] class.
  ///
  /// [turnDetails] A list of [ChatTurnDetails] objects.
  ChatDetails({List<ChatTurnDetails>? turnDetails = null})
    : turnDetails = turnDetails;

  /// Gets or sets the [ChatTurnDetails] for the LLM chat conversation turns
  /// recorded in this [ChatDetails] object.
  List<ChatTurnDetails> turnDetails;
}
