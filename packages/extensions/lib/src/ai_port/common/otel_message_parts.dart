import '../abstractions/functions/ai_function_declaration.dart';
import '../abstractions/tools/ai_tool.dart';

class OtelBlobPart {
  OtelBlobPart();

  String type = "blob";

  String? content;

  String? mimeType;

  String? modality;

}
class OtelFilePart {
  OtelFilePart();

  String type = "file";

  String? fileId;

  String? mimeType;

  String? modality;

}
class OtelFunction {
  OtelFunction();

  String type = "function";

  String? name;

  String? description;

  JsonElement? parameters;

  /// Builds an [OtelFunction] from an [AITool].
  ///
  /// [tool] The tool to describe.
  ///
  /// [includeOptionalProperties] When `false`, the optional [Description] and
  /// [Parameters] properties will be set to `null`, as they may contain
  /// sensitive, user-authored values or large payloads.
  static OtelFunction create(ATool tool, bool includeOptionalProperties, ) {
    if (tool.getService<AFunctionDeclaration>() is { } function) {
      return new()
            {
                name = function.name,
                description = includeOptionalProperties ? function.description : null,
                parameters = includeOptionalProperties ? function.jsonSchema : null,
            };
    }
    return new()
        {
            type = tool.name,
            name = tool.name,
        };
  }
}
class OtelGenericPart {
  OtelGenericPart();

  String type = "text";

  Object? content;

}
class OtelMcpToolCall {
  OtelMcpToolCall();

  String type = "mcp";

  String? serverName;

  Map<String, Object?>? arguments;

}
class OtelMcpToolCallResponse {
  OtelMcpToolCallResponse();

  String type = "mcp";

  Object? output;

}
class OtelServerToolCallPart<T> {
  OtelServerToolCallPart();

  String type = "server_tool_call";

  String? id;

  String? name;

  T? serverToolCall;

}
class OtelServerToolCallResponsePart<T> {
  OtelServerToolCallResponsePart();

  String type = "server_tool_call_response";

  String? id;

  T? serverToolCallResponse;

}
class OtelToolCallResponsePart {
  OtelToolCallResponsePart();

  String type = "tool_call_response";

  String? id;

  Object? response;

}
class OtelUriPart {
  OtelUriPart();

  String type = "uri";

  String? uri;

  String? mimeType;

  String? modality;

}
