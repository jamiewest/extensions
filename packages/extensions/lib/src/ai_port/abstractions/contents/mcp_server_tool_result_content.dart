import 'ai_content.dart';
import 'tool_result_content.dart';

/// Represents the result of a MCP server tool call.
///
/// Remarks: This content type is used to represent the result of an
/// invocation of an MCP server tool by a hosted service. It is informational
/// only.
class McpServerToolResultContent extends ToolResultContent {
  /// Initializes a new instance of the [McpServerToolResultContent] class.
  ///
  /// [callId] The tool call ID.
  const McpServerToolResultContent(String callId);

  /// Gets or sets the output contents of the tool call.
  List<AContent>? outputs;
}
