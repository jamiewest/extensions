import 'package:extensions/annotations.dart';

import 'tool_call_content.dart';

/// Represents a tool call request to an MCP server by a hosted service.
///
/// This is informational only — it may appear as part of an approval request
/// or as a record of which MCP server tool was invoked.
@Source(
  name: 'McpServerToolCallContent.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Contents/',
)
class McpServerToolCallContent extends ToolCallContent {
  /// Creates a new [McpServerToolCallContent].
  McpServerToolCallContent({
    required super.callId,
    required this.toolName,
    this.serverName,
    this.arguments,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// The name of the MCP tool being called.
  final String toolName;

  /// The name of the MCP server that hosts the tool.
  final String? serverName;

  /// The arguments to pass to the tool.
  Map<String, Object?>? arguments;
}
