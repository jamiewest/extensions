import 'ai_content.dart';

/// Represents an MCP server tool call.
///
/// This is an experimental feature.
class McpServerToolCallContent extends AIContent {
  /// Creates a new [McpServerToolCallContent].
  McpServerToolCallContent({
    required this.callId,
    required this.toolName,
    this.serverName,
    this.arguments,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// The unique identifier for this tool call.
  final String callId;

  /// The name of the tool being called.
  final String toolName;

  /// The name of the MCP server.
  final String? serverName;

  /// The arguments for the tool call.
  final Map<String, Object?>? arguments;

  @override
  String toString() => 'McpServerToolCall($callId, $toolName)';
}

/// Represents the result of an MCP server tool call.
///
/// This is an experimental feature.
class McpServerToolResultContent extends AIContent {
  /// Creates a new [McpServerToolResultContent].
  McpServerToolResultContent({
    required this.callId,
    this.output,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// The unique identifier for the corresponding tool call.
  final String callId;

  /// The output content items.
  final List<AIContent>? output;

  @override
  String toString() => 'McpServerToolResult($callId)';
}
