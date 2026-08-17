import 'ai_content.dart';

/// Base class for content types that represent the result of a tool call.
abstract class ToolResultContent extends AIContent {
  /// Creates a new [ToolResultContent].
  ToolResultContent({
    required this.callId,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// The ID of the [ToolCallContent] this result corresponds to.
  final String callId;
}
