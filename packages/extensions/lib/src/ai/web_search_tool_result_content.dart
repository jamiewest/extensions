import 'package:extensions/annotations.dart';

import 'ai_content.dart';
import 'tool_result_content.dart';

/// Represents the result of a web search tool invocation by a hosted service.
///
/// Each output typically represents a web page result, usually as a
/// [UriContent]. A title may be stored in [AIContent.additionalProperties]
/// under the key `"title"`.
@Source(
  name: 'WebSearchToolResultContent.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Contents/',
)
class WebSearchToolResultContent extends ToolResultContent {
  /// Creates a new [WebSearchToolResultContent].
  WebSearchToolResultContent({
    required super.callId,
    this.outputs,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// The web search result items (typically [UriContent] instances).
  List<AIContent>? outputs;
}
