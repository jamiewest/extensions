import '../../abstractions/functions/ai_function_declaration.dart';
import '../../abstractions/tools/ai_tool.dart';

extension AToolExtensions on Iterable<ATool> {
  String renderAsJson({JsonSerializerOptions? options}) {
    _ = Throw.ifNull(toolDefinitions);
    var toolDefinitionsJsonArray = jsonArray();
    for (final function in toolDefinitions.ofType<AFunctionDeclaration>()) {
      var functionJsonNode = jsonObject();
      if (function.returnJsonSchema != null) {
        functionJsonNode["functionReturnValueSchema"] = JsonNode.parse(
          function.returnJsonSchema.value.getRawText(),
        );
      }
      toolDefinitionsJsonArray.add(functionJsonNode);
    }
    var renderedToolDefinitions = toolDefinitionsJsonArray.toJsonString(
      options,
    );
    return renderedToolDefinitions;
  }
}
