import 'tool_call_content.dart';

/// Represents a tool call request to a MCP server.
///
/// Remarks: This content type is used to represent an invocation of an MCP
/// server tool by a hosted service. It is informational only and may appear
/// as part of an approval request to convey what is being approved, or as a
/// record of which MCP server tool was invoked.
class McpServerToolCallContent extends ToolCallContent {
  /// Initializes a new instance of the [McpServerToolCallContent] class.
  ///
  /// Remarks: This content is informational only and may appear as part of an
  /// approval request to convey what is being approved, or as a record of which
  /// MCP server tool was invoked.
  ///
  /// [callId] The tool call ID.
  ///
  /// [name] The tool name.
  ///
  /// [serverName] The MCP server name that hosts the tool.
  const McpServerToolCallContent(String callId, String name, String? serverName)
    : name = Throw.ifNullOrWhitespace(name),
      serverName = serverName;

  /// Gets the name of the tool requested.
  final String name;

  /// Gets the name of the MCP server that hosts the tool.
  final String? serverName;

  /// Gets or sets the arguments requested to be provided to the tool.
  Map<String, Object?>? arguments;
}
