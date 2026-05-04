import 'tool_call_content.dart';

/// Represents a web search tool call invocation by a hosted service.
///
/// Remarks: This content type represents when a hosted AI service invokes a
/// web search tool. It is informational only and represents the call itself,
/// not the result.
class WebSearchToolCallContent extends ToolCallContent {
  /// Initializes a new instance of the [WebSearchToolCallContent] class.
  ///
  /// [callId] The tool call ID.
  const WebSearchToolCallContent(String callId);

  /// Gets or sets the search queries issued by the service.
  List<String>? queries;
}
