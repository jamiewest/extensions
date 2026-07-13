import 'package:extensions/annotations.dart';

import '../functions/ai_function_declaration.dart';
import '../tools/ai_tool.dart';

/// Shared OTel message-part objects.
///
/// These model the OpenTelemetry Semantic Conventions for Generative AI
/// message-parts shape. The upstream C# POCOs that diverge between the chat
/// and realtime clients are co-located here because Dart has no
/// assembly-internal visibility to split them across client files.
///
/// Not exported from the `ai` barrel; this mirrors the C# `internal` types.
@Source(
  name: 'OtelMessageParts.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI/Common/',
)
class OtelMessage {
  /// Creates a new [OtelMessage].
  OtelMessage({this.role, this.name, this.finishReason});

  /// The chat role, normalized to the OTel convention values.
  String? role;

  /// The author name, if any.
  String? name;

  /// The finish reason, recorded on every message of a response.
  String? finishReason;

  /// The message parts.
  final List<Object> parts = [];

  /// Converts this message to a JSON-encodable map.
  Map<String, Object?> toJson() => {
        if (role != null) 'role': role,
        if (name != null) 'name': name,
        if (finishReason != null) 'finish_reason': finishReason,
        'parts': parts,
      };
}

/// A generic part carrying text or extensibility content.
class OtelGenericPart {
  /// Creates a new [OtelGenericPart].
  OtelGenericPart({this.type = 'text', this.content});

  /// The part type.
  final String type;

  /// The content; a string when [type] is `"text"`.
  final Object? content;

  /// Converts this part to a JSON-encodable map.
  Map<String, Object?> toJson() => {'type': type, 'content': content};
}

/// A binary-data part.
class OtelBlobPart {
  /// Creates a new [OtelBlobPart].
  OtelBlobPart({this.content, this.mimeType, this.modality});

  /// Base64-encoded binary data.
  final String? content;

  /// The media type of the data.
  final String? mimeType;

  /// The derived modality (`image`, `audio`, or `video`).
  final String? modality;

  /// Converts this part to a JSON-encodable map.
  Map<String, Object?> toJson() => {
        'type': 'blob',
        'content': content,
        'mime_type': mimeType,
        'modality': modality,
      };
}

/// A URI-referenced content part.
class OtelUriPart {
  /// Creates a new [OtelUriPart].
  OtelUriPart({this.uri, this.mimeType, this.modality});

  /// The absolute URI of the content.
  final String? uri;

  /// The media type of the content.
  final String? mimeType;

  /// The derived modality (`image`, `audio`, or `video`).
  final String? modality;

  /// Converts this part to a JSON-encodable map.
  Map<String, Object?> toJson() => {
        'type': 'uri',
        'uri': uri,
        'mime_type': mimeType,
        'modality': modality,
      };
}

/// A hosted-file content part.
class OtelFilePart {
  /// Creates a new [OtelFilePart].
  OtelFilePart({this.fileId, this.mimeType, this.modality});

  /// The provider-specific file identifier.
  final String? fileId;

  /// The media type of the file.
  final String? mimeType;

  /// The derived modality (`image`, `audio`, or `video`).
  final String? modality;

  /// Converts this part to a JSON-encodable map.
  Map<String, Object?> toJson() => {
        'type': 'file',
        'file_id': fileId,
        'mime_type': mimeType,
        'modality': modality,
      };
}

/// A tool-call request part.
class OtelToolCallRequestPart {
  /// Creates a new [OtelToolCallRequestPart].
  OtelToolCallRequestPart({this.id, this.name, this.arguments});

  /// The tool call identifier.
  final String? id;

  /// The tool name.
  final String? name;

  /// The tool call arguments.
  final Map<String, Object?>? arguments;

  /// Converts this part to a JSON-encodable map.
  Map<String, Object?> toJson() => {
        'type': 'tool_call',
        'id': id,
        'name': name,
        'arguments': arguments,
      };
}

/// A tool-call response part.
class OtelToolCallResponsePart {
  /// Creates a new [OtelToolCallResponsePart].
  OtelToolCallResponsePart({this.id, this.response});

  /// The tool call identifier.
  final String? id;

  /// The tool result.
  final Object? response;

  /// Converts this part to a JSON-encodable map.
  Map<String, Object?> toJson() => {
        'type': 'tool_call_response',
        'id': id,
        'response': response,
      };
}

/// A server-side tool-call part.
class OtelServerToolCallPart {
  /// Creates a new [OtelServerToolCallPart].
  OtelServerToolCallPart({this.id, this.name, this.serverToolCall});

  /// The tool call identifier.
  final String? id;

  /// The tool name.
  final String? name;

  /// The tool-specific call payload.
  final Object? serverToolCall;

  /// Converts this part to a JSON-encodable map.
  Map<String, Object?> toJson() => {
        'type': 'server_tool_call',
        'id': id,
        'name': name,
        'server_tool_call': serverToolCall,
      };
}

/// A server-side tool-call response part.
class OtelServerToolCallResponsePart {
  /// Creates a new [OtelServerToolCallResponsePart].
  OtelServerToolCallResponsePart({this.id, this.serverToolCallResponse});

  /// The tool call identifier.
  final String? id;

  /// The tool-specific response payload.
  final Object? serverToolCallResponse;

  /// Converts this part to a JSON-encodable map.
  Map<String, Object?> toJson() => {
        'type': 'server_tool_call_response',
        'id': id,
        'server_tool_call_response': serverToolCallResponse,
      };
}

/// A code-interpreter server tool call payload.
class OtelCodeInterpreterToolCall {
  /// Creates a new [OtelCodeInterpreterToolCall].
  OtelCodeInterpreterToolCall({this.code});

  /// The code to execute.
  final String? code;

  /// Converts this payload to a JSON-encodable map.
  Map<String, Object?> toJson() => {'type': 'code_interpreter', 'code': code};
}

/// A code-interpreter server tool call response payload.
class OtelCodeInterpreterToolCallResponse {
  /// Creates a new [OtelCodeInterpreterToolCallResponse].
  OtelCodeInterpreterToolCallResponse({this.output});

  /// The interpreter outputs.
  final Object? output;

  /// Converts this payload to a JSON-encodable map.
  Map<String, Object?> toJson() =>
      {'type': 'code_interpreter', 'output': output};
}

/// An image-generation server tool call payload.
class OtelImageGenerationToolCall {
  /// Creates a new [OtelImageGenerationToolCall].
  OtelImageGenerationToolCall();

  /// Converts this payload to a JSON-encodable map.
  Map<String, Object?> toJson() => {'type': 'image_generation'};
}

/// An image-generation server tool call response payload.
class OtelImageGenerationToolCallResponse {
  /// Creates a new [OtelImageGenerationToolCallResponse].
  OtelImageGenerationToolCallResponse({this.output});

  /// The generated outputs.
  final Object? output;

  /// Converts this payload to a JSON-encodable map.
  Map<String, Object?> toJson() =>
      {'type': 'image_generation', 'output': output};
}

/// An MCP server tool call payload.
class OtelMcpToolCall {
  /// Creates a new [OtelMcpToolCall].
  OtelMcpToolCall({this.serverName, this.arguments});

  /// The MCP server name.
  final String? serverName;

  /// The tool call arguments.
  final Map<String, Object?>? arguments;

  /// Converts this payload to a JSON-encodable map.
  Map<String, Object?> toJson() => {
        'type': 'mcp',
        'server_name': serverName,
        'arguments': arguments,
      };
}

/// An MCP server tool call response payload.
class OtelMcpToolCallResponse {
  /// Creates a new [OtelMcpToolCallResponse].
  OtelMcpToolCallResponse({this.output});

  /// The tool outputs.
  final Object? output;

  /// Converts this payload to a JSON-encodable map.
  Map<String, Object?> toJson() => {'type': 'mcp', 'output': output};
}

/// An MCP approval-request payload.
class OtelMcpApprovalRequest {
  /// Creates a new [OtelMcpApprovalRequest].
  OtelMcpApprovalRequest({this.serverName, this.arguments});

  /// The MCP server name.
  final String? serverName;

  /// The pending tool call arguments.
  final Map<String, Object?>? arguments;

  /// Converts this payload to a JSON-encodable map.
  Map<String, Object?> toJson() => {
        'type': 'mcp',
        'server_name': serverName,
        'arguments': arguments,
      };
}

/// An MCP approval-response payload.
class OtelMcpApprovalResponse {
  /// Creates a new [OtelMcpApprovalResponse].
  OtelMcpApprovalResponse({this.approved});

  /// Whether the tool call was approved.
  final bool? approved;

  /// Converts this payload to a JSON-encodable map.
  Map<String, Object?> toJson() => {'type': 'mcp', 'approved': approved};
}

/// A tool definition descriptor.
class OtelFunction {
  /// Creates a new [OtelFunction].
  OtelFunction(
      {this.type = 'function', this.name, this.description, this.parameters});

  /// The tool type.
  final String type;

  /// The tool name.
  final String? name;

  /// The tool description.
  final String? description;

  /// The JSON schema for the tool parameters.
  final Map<String, Object?>? parameters;

  /// Builds an [OtelFunction] from an [AITool].
  ///
  /// When [includeOptionalProperties] is `false`, the optional
  /// [description] and [parameters] properties are left `null`, as they
  /// may contain sensitive, user-authored values or large payloads.
  static OtelFunction create(
    AITool tool, {
    required bool includeOptionalProperties,
  }) {
    if (tool is AIFunctionDeclaration) {
      return OtelFunction(
        name: tool.name,
        description: includeOptionalProperties ? tool.description : null,
        parameters: includeOptionalProperties ? tool.parametersSchema : null,
      );
    }
    return OtelFunction(type: tool.name, name: tool.name);
  }

  /// Converts this descriptor to a JSON-encodable map.
  Map<String, Object?> toJson() => {
        'type': type,
        'name': name,
        'description': description,
        'parameters': parameters,
      };
}
