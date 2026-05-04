import 'ai_content.dart';

/// Represents a tool call request.
class ToolCallContent extends AContent {
  /// Initializes a new instance of the [ToolCallContent] class.
  ///
  /// [callId] The tool call ID.
  const ToolCallContent(String callId) : callId = Throw.ifNull(callId);

  /// Gets the tool call ID.
  final String callId;
}
