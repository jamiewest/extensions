import 'ai_content.dart';
import 'tool_call_content.dart';

/// Represents the result of a tool call.
class ToolResultContent extends AContent {
  /// Initializes a new instance of the [ToolResultContent] class.
  ///
  /// [callId] The tool call ID for which this is the result.
  const ToolResultContent(String callId) : callId = Throw.ifNull(callId);

  /// Gets the ID of the tool call for which this is the result.
  ///
  /// Remarks: If this is the result for a [ToolCallContent], this property
  /// should contain the same [CallId] value.
  final String callId;
}
