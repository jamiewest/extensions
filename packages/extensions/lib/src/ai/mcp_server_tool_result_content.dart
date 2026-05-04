import 'package:extensions/annotations.dart';

import 'ai_content.dart';
import 'tool_result_content.dart';

/// Represents the result of an MCP server tool call by a hosted service.
///
/// This is informational only.
@Source(
  name: 'McpServerToolResultContent.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Contents/',
)
class MCPServerToolResultContent extends ToolResultContent {
  /// Creates a new [MCPServerToolResultContent].
  MCPServerToolResultContent({
    required super.callId,
    this.outputs,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// The output contents produced by the MCP server tool.
  List<AIContent>? outputs;
}
