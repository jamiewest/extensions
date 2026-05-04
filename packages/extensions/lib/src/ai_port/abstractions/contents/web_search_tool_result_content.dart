import 'ai_content.dart';
import 'tool_result_content.dart';
import 'uri_content.dart';

/// Represents the result of a web search tool invocation by a hosted service.
///
/// Remarks: This content type represents the results found by a hosted AI
/// service's web search tool. The results contain a list of [AIContent] items
/// describing the web pages found during the search, typically as
/// [UriContent] instances.
class WebSearchToolResultContent extends ToolResultContent {
  /// Initializes a new instance of the [WebSearchToolResultContent] class.
  ///
  /// [callId] The tool call ID.
  const WebSearchToolResultContent(String callId);

  /// Gets or sets the web search outputs.
  ///
  /// Remarks: Each output represents a web page result found during the search,
  /// typically as a [UriContent] instance. If a title is available for a
  /// result, it may be stored in the item's [AdditionalProperties] under the
  /// key `"title"`.
  List<AContent>? outputs;
}
