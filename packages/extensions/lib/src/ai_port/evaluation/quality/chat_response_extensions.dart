import '../../abstractions/contents/function_call_content.dart';
import '../../abstractions/contents/function_result_content.dart';

extension ChatResponseExtensions on ChatResponse {String renderAsJson({JsonSerializerOptions? options}) {
_ = Throw.ifNull(modelResponse);
return modelResponse.messages.renderAsJson(options);
 }
String renderToolCallsAndResultsAsJson({JsonSerializerOptions? options}) {
_ = Throw.ifNull(modelResponse);
var toolCallsAndResultsJsonArray = jsonArray();
for (final content in modelResponse.messages.selectMany((m) => m.contents)) {
  if (content is FunctionCallContent or FunctionResultContent) {
    var contentType = content is FunctionCallContent ? typeof(FunctionCallContent) : typeof(FunctionResultContent);
    var toolCallOrResultJsonNode = JsonSerializer.serializeToNode(
                        content,
                        AIJsonUtilities.defaultOptions.getTypeInfo(contentType));
    if (toolCallOrResultJsonNode != null) {
      toolCallsAndResultsJsonArray.add(toolCallOrResultJsonNode);
    }
  }
}
var renderedToolCallsAndResults = toolCallsAndResultsJsonArray.toJsonString(options);
return renderedToolCallsAndResults;
 }
 }
