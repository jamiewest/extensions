import '../abstractions/chat_completion/chat_finish_reason.dart';
import '../abstractions/chat_completion/chat_message.dart';
import '../abstractions/chat_completion/chat_role.dart';
import '../abstractions/contents/ai_content.dart';
import '../abstractions/contents/code_interpreter_tool_call_content.dart';
import '../abstractions/contents/code_interpreter_tool_result_content.dart';
import '../abstractions/contents/data_content.dart';
import '../abstractions/contents/error_content.dart';
import '../abstractions/contents/function_call_content.dart';
import '../abstractions/contents/function_result_content.dart';
import '../abstractions/contents/hosted_file_content.dart';
import '../abstractions/contents/hosted_vector_store_content.dart';
import '../abstractions/contents/image_generation_tool_call_content.dart';
import '../abstractions/contents/image_generation_tool_result_content.dart';
import '../abstractions/contents/mcp_server_tool_call_content.dart';
import '../abstractions/contents/mcp_server_tool_result_content.dart';
import '../abstractions/contents/text_content.dart';
import '../abstractions/contents/text_reasoning_content.dart';
import '../abstractions/contents/tool_approval_request_content.dart';
import '../abstractions/contents/tool_approval_response_content.dart';
import '../abstractions/contents/uri_content.dart';
import '../chat_completion/open_telemetry_chat_client.dart';
import 'otel_context.dart';
import 'otel_message_parts.dart';

/// Shared helpers for serializing chat messages to the OpenTelemetry gen-ai
/// message-parts shape.
class OtelMessageSerializer {
  OtelMessageSerializer();

  static final JsonSerializerOptions defaultOptions = CreateDefaultOptions();

  static final JsonElement _emptyObject = JsonSerializer.SerializeToElement(
    object(),
    DefaultOptions.GetTypeInfo(typeof(object)),
  );

  static JsonSerializerOptions createDefaultOptions() {
    var options = new(OtelContext.defaultValue.options)
        {
            Encoder = JavaScriptEncoder.unsafeRelaxedJsonEscaping
        };
    options.typeInfoResolverChain.add(AIJsonUtilities.defaultOptions.typeInfoResolver!);
    options.makeReadOnly();
    return options;
  }

  static String serializeChatMessages(
    Iterable<ChatMessage> messages,
    {ChatFinishReason? chatFinishReason, JsonSerializerOptions? customContentSerializerOptions, },
  ) {
    var output = [];
    var finishReason = chatFinishReason?.value == null ? null :
            chatFinishReason == ChatFinishReason.length ? "length" :
            chatFinishReason == ChatFinishReason.contentFilter ? "content_filter" :
            chatFinishReason == ChatFinishReason.toolCalls ? "tool_call" :
            "stop";
    for (final message in messages) {
      var m = new()
            {
                FinishReason = finishReason,
                Role =
                    message.role == ChatRole.assistant ? "assistant" :
                    message.role == ChatRole.tool ? "tool" :
                    message.role == ChatRole.system || message.role == chatRole("developer") ? "system" :
                    "user",
                Name = message.authorName,
            };
      for (final content in message.contents) {
        switch (content) {
          case TextContent tc:
          m.parts.add(otelGenericPart());
          case TextReasoningContent trc:
          m.parts.add(otelGenericPart());
          case FunctionCallContent fcc:
          m.parts.add(otelToolCallRequestPart());
          case FunctionResultContent frc:
          m.parts.add(otelToolCallResponsePart());
          case DataContent dc:
          m.parts.add(otelBlobPart());
          case UriContent uc:
          m.parts.add(otelUriPart());
          case HostedFileContent fc:
          m.parts.add(otelFilePart());
          case HostedVectorStoreContent vsc:
          m.parts.add(otelGenericPart());
          case ErrorContent ec:
          m.parts.add(otelGenericPart());
          case CodeInterpreterToolCallContent citcc:
          m.parts.add(OtelServerToolCallPart<OtelCodeInterpreterToolCall>(),
                        });
        case CodeInterpreterToolResultContent citrc:
        m.parts.add(OtelServerToolCallResponsePart<OtelCodeInterpreterToolCallResponse>(),
                        });
      case ImageGenerationToolCallContent igtcc:
        m.parts.add(OtelServerToolCallPart<OtelImageGenerationToolCall>());
      case ImageGenerationToolResultContent igtrc:
        m.parts.add(OtelServerToolCallResponsePart<OtelImageGenerationToolCallResponse>(),
                        });
      case McpServerToolCallContent mstcc:
        m.parts.add(OtelServerToolCallPart<OtelMcpToolCall>(),
                        });
      case McpServerToolResultContent mstrc:
        m.parts.add(OtelServerToolCallResponsePart<OtelMcpToolCallResponse>(),
                        });
      case ToolApprovalRequestContent fareqc:
        m.parts.add(OtelServerToolCallPart<OtelMcpApprovalRequest>(),
                        });
      case ToolApprovalResponseContent farespc:
        m.parts.add(OtelServerToolCallResponsePart<OtelMcpApprovalResponse>(),
                        });
      default:
        var element = _emptyObject;
        try {
          var unknownContentTypeInfo = customContentSerializerOptions?.tryGetTypeInfo(
            content.getType(),
            out JsonTypeInfo? ctsi,
          ) is true ? ctsi :
                                defaultOptions.tryGetTypeInfo(
                                  content.getType(),
                                  out JsonTypeInfo? dtsi,
                                ) ? dtsi :
                                null;
          if (unknownContentTypeInfo != null) {
            element = JsonSerializer.serializeToElement(content, unknownContentTypeInfo);
    }
        } catch (e, s) {
          {}
  }

        m.parts.add(otelGenericPart());
}
  }

  output.add(m);
}
return JsonSerializer.serialize(output, defaultOptions.getTypeInfo(typeof(IList<object>)));
 }
/// Derives the OTel `modality` classifier from a media type's top-level type.
static String? deriveModalityFromMediaType(String? mediaType) {
if (mediaType != null) {
  var pos = mediaType.indexOf('/');
  if (pos >= 0) {
    var topLevel = mediaType.asSpan(0, pos);
    return topLevel.equals("image", StringComparison.ordinalIgnoreCase) ? "image" :
                    topLevel.equals("audio", StringComparison.ordinalIgnoreCase) ? "audio" :
                    topLevel.equals("video", StringComparison.ordinalIgnoreCase) ? "video" :
                    null;
  }
}
return null;
 }
/// Extracts code text from code interpreter inputs.
///
/// Remarks: Code interpreter inputs typically contain a DataContent with a
/// "text/x-python" or similar media type representing the code to execute.
static String? extractCodeFromInputs(List<AContent>? inputs) {
if (inputs != null) {
  for (final input in inputs) {
    if (input is DataContent dc && dc.hasTopLevelMediaType("text")) {
      return Encoding.utF8.getString(dc.data.toArray());
    }
    if (input is TextContent tc && !string.isNullOrEmpty(tc.text)) {
      return tc.text;
    }
  }
}
return null;
 }
 }
