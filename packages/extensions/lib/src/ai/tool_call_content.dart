import 'ai_content.dart';

/// Base class for content types that represent a tool call request.
abstract class ToolCallContent extends AIContent {
  /// Creates a new [ToolCallContent].
  ToolCallContent({
    required this.callId,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// The unique identifier for this tool call.
  final String callId;
}
