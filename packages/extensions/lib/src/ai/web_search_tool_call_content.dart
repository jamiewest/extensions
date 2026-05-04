import 'package:extensions/annotations.dart';

import 'tool_call_content.dart';

/// Represents a web search tool call invoked by a hosted service.
///
/// This is informational only and represents the call itself, not its result.
@Source(
  name: 'WebSearchToolCallContent.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Contents/',
)
class WebSearchToolCallContent extends ToolCallContent {
  /// Creates a new [WebSearchToolCallContent].
  WebSearchToolCallContent({
    required super.callId,
    this.queries,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// The search queries issued by the service.
  List<String>? queries;
}
