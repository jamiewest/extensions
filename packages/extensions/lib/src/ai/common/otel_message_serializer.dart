import 'dart:convert';

import '../ai_content.dart';
import '../chat_completion/chat_finish_reason.dart';
import '../chat_completion/chat_message.dart';
import '../chat_completion/chat_role.dart';
import '../code_interpreter_tool_call_content.dart';
import '../code_interpreter_tool_result_content.dart';
import '../data_content.dart';
import '../error_content.dart';
import '../function_call_content.dart';
import '../function_result_content.dart';
import '../hosted_file_content.dart';
import '../hosted_vector_store_content.dart';
import '../image_generation_tool_call_content.dart';
import '../image_generation_tool_result_content.dart';
import '../mcp_server_tool_call_content.dart';
import '../mcp_server_tool_result_content.dart';
import '../text_content.dart';
import '../text_reasoning_content.dart';
import '../tool_approval_request_content.dart';
import '../tool_approval_response_content.dart';
import '../uri_content.dart';
import 'otel_message_parts.dart';

/// Shared helpers for serializing chat messages to the OpenTelemetry
/// gen-ai message-parts shape.
///
/// The upstream System.Text.Json machinery (`OtelContext`,
/// `AIJsonUtilities` resolver chains) is replaced with plain
/// `dart:convert` maps; unknown values fall back to their string
/// representation rather than throwing.
///
/// Not exported from the `ai` barrel; this mirrors the C# `internal`
/// type.
abstract final class OtelMessageSerializer {
  /// Serializes [messages] to a JSON string in the OTel gen-ai
  /// message-parts shape.
  ///
  /// When [finishReason] is provided, it is recorded on every message,
  /// matching the upstream convention for response messages.
  static String serializeChatMessages(
    Iterable<ChatMessage> messages, {
    ChatFinishReason? finishReason,
  }) {
    final output = <Object>[];

    final String? reason;
    if (finishReason == null) {
      reason = null;
    } else if (finishReason == ChatFinishReason.length) {
      reason = 'length';
    } else if (finishReason == ChatFinishReason.contentFilter) {
      reason = 'content_filter';
    } else if (finishReason == ChatFinishReason.toolCalls) {
      reason = 'tool_call';
    } else {
      reason = 'stop';
    }

    for (final message in messages) {
      final m = OtelMessage(
        finishReason: reason,
        role: _mapRole(message.role),
        name: message.authorName,
      );

      for (final content in message.contents) {
        final part = _mapContent(content);
        if (part != null) {
          m.parts.add(part);
        }
      }

      output.add(m);
    }

    return jsonEncode(output, toEncodable: _toEncodable);
  }

  /// Derives the OTel `modality` classifier from a media type's
  /// top-level type.
  static String? deriveModalityFromMediaType(String? mediaType) {
    if (mediaType != null) {
      final pos = mediaType.indexOf('/');
      if (pos >= 0) {
        final topLevel = mediaType.substring(0, pos).toLowerCase();
        return switch (topLevel) {
          'image' => 'image',
          'audio' => 'audio',
          'video' => 'video',
          _ => null,
        };
      }
    }
    return null;
  }

  static String _mapRole(ChatRole role) {
    if (role == ChatRole.assistant) return 'assistant';
    if (role == ChatRole.tool) return 'tool';
    if (role == ChatRole.system || role == const ChatRole('developer')) {
      return 'system';
    }
    return 'user';
  }

  static Object? _mapContent(AIContent content) {
    switch (content) {
      case TextContent(:final text) when text.trim().isNotEmpty:
        return OtelGenericPart(content: text);
      case TextReasoningContent(:final text) when text.trim().isNotEmpty:
        return OtelGenericPart(type: 'reasoning', content: text);
      case FunctionCallContent():
        return OtelToolCallRequestPart(
          id: content.callId,
          name: content.name,
          arguments: content.arguments,
        );
      case FunctionResultContent():
        return OtelToolCallResponsePart(
          id: content.callId,
          response: content.result,
        );
      case DataContent():
        return OtelBlobPart(
          content: content.data != null ? base64Encode(content.data!) : null,
          mimeType: content.mediaType,
          modality: deriveModalityFromMediaType(content.mediaType),
        );
      case UriContent():
        return OtelUriPart(
          uri: content.uri.toString(),
          mimeType: content.mediaType,
          modality: deriveModalityFromMediaType(content.mediaType),
        );
      case HostedFileContent():
        return OtelFilePart(
          fileId: content.fileId,
          mimeType: content.mediaType,
          modality: deriveModalityFromMediaType(content.mediaType),
        );
      case HostedVectorStoreContent():
        return OtelGenericPart(
          type: 'vector_store',
          content: content.vectorStoreId,
        );
      case ErrorContent():
        return OtelGenericPart(type: 'error', content: content.message);
      case CodeInterpreterToolCallContent():
        return OtelServerToolCallPart(
          id: content.callId,
          name: 'code_interpreter',
          serverToolCall: OtelCodeInterpreterToolCall(
            code: _extractCodeFromInputs(content.inputs),
          ),
        );
      case CodeInterpreterToolResultContent():
        return OtelServerToolCallResponsePart(
          id: content.callId,
          serverToolCallResponse: OtelCodeInterpreterToolCallResponse(
            output: content.outputs,
          ),
        );
      case ImageGenerationToolCallContent():
        return OtelServerToolCallPart(
          id: content.callId,
          name: 'image_generation',
          serverToolCall: OtelImageGenerationToolCall(),
        );
      case ImageGenerationToolResultContent():
        return OtelServerToolCallResponsePart(
          id: content.callId,
          serverToolCallResponse: OtelImageGenerationToolCallResponse(
            output: content.outputs,
          ),
        );
      case McpServerToolCallContent():
        return OtelServerToolCallPart(
          id: content.callId,
          name: content.toolName,
          serverToolCall: OtelMcpToolCall(
            serverName: content.serverName,
            arguments: content.arguments,
          ),
        );
      case MCPServerToolResultContent():
        return OtelServerToolCallResponsePart(
          id: content.callId,
          serverToolCallResponse: OtelMcpToolCallResponse(
            output: content.outputs,
          ),
        );
      case ToolApprovalRequestContent(
        toolCall: final McpServerToolCallContent mcpToolCall,
      ):
        return OtelServerToolCallPart(
          id: content.requestId,
          name: mcpToolCall.toolName,
          serverToolCall: OtelMcpApprovalRequest(
            serverName: mcpToolCall.serverName,
            arguments: mcpToolCall.arguments,
          ),
        );
      case ToolApprovalResponseContent(toolCall: McpServerToolCallContent()):
        return OtelServerToolCallResponsePart(
          id: content.requestId,
          serverToolCallResponse: OtelMcpApprovalResponse(
            approved: content.approved,
          ),
        );
      case TextContent():
      case TextReasoningContent():
        return null;
      default:
        return OtelGenericPart(
          type: content.runtimeType.toString(),
          content: const <String, Object?>{},
        );
    }
  }

  static String? _extractCodeFromInputs(List<AIContent>? inputs) {
    if (inputs != null) {
      for (final input in inputs) {
        if (input is DataContent && input.hasTopLevelMediaType('text')) {
          final data = input.data;
          if (data != null) {
            return utf8.decode(data, allowMalformed: true);
          }
        }
        if (input is TextContent && input.text.isNotEmpty) {
          return input.text;
        }
      }
    }
    return null;
  }

  static Object? _toEncodable(Object? value) {
    if (value is OtelMessage) return value.toJson();
    if (value is OtelGenericPart) return value.toJson();
    if (value is OtelBlobPart) return value.toJson();
    if (value is OtelUriPart) return value.toJson();
    if (value is OtelFilePart) return value.toJson();
    if (value is OtelToolCallRequestPart) return value.toJson();
    if (value is OtelToolCallResponsePart) return value.toJson();
    if (value is OtelServerToolCallPart) return value.toJson();
    if (value is OtelServerToolCallResponsePart) return value.toJson();
    if (value is OtelCodeInterpreterToolCall) return value.toJson();
    if (value is OtelCodeInterpreterToolCallResponse) return value.toJson();
    if (value is OtelImageGenerationToolCall) return value.toJson();
    if (value is OtelImageGenerationToolCallResponse) return value.toJson();
    if (value is OtelMcpToolCall) return value.toJson();
    if (value is OtelMcpToolCallResponse) return value.toJson();
    if (value is OtelMcpApprovalRequest) return value.toJson();
    if (value is OtelMcpApprovalResponse) return value.toJson();
    if (value is OtelFunction) return value.toJson();
    return value.toString();
  }
}
