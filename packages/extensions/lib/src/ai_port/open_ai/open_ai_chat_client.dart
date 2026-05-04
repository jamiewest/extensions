import '../../../../../lib/func_typedefs.dart';
import '../abstractions/chat_completion/auto_chat_tool_mode.dart';
import '../abstractions/chat_completion/chat_client.dart';
import '../abstractions/chat_completion/chat_client_metadata.dart';
import '../abstractions/chat_completion/chat_finish_reason.dart';
import '../abstractions/chat_completion/chat_message.dart';
import '../abstractions/chat_completion/chat_options.dart';
import '../abstractions/chat_completion/chat_response_format.dart';
import '../abstractions/chat_completion/chat_response_format_json.dart';
import '../abstractions/chat_completion/chat_response_format_text.dart';
import '../abstractions/chat_completion/chat_response_update.dart';
import '../abstractions/chat_completion/chat_role.dart';
import '../abstractions/chat_completion/none_chat_tool_mode.dart';
import '../abstractions/chat_completion/reasoning_effort.dart';
import '../abstractions/chat_completion/required_chat_tool_mode.dart';
import '../abstractions/contents/ai_content.dart';
import '../abstractions/contents/citation_annotation.dart';
import '../abstractions/contents/data_content.dart';
import '../abstractions/contents/error_content.dart';
import '../abstractions/contents/function_call_content.dart';
import '../abstractions/contents/hosted_file_content.dart';
import '../abstractions/contents/text_content.dart';
import '../abstractions/contents/text_reasoning_content.dart';
import '../abstractions/contents/uri_content.dart';
import '../abstractions/contents/usage_content.dart';
import '../abstractions/functions/ai_function_declaration.dart';
import '../abstractions/tools/hosted_web_search_tool.dart';
import '../abstractions/usage_details.dart';
import 'open_ai_client_extensions.dart';
import 'open_ai_json_context.dart';
import 'open_ai_request_policies.dart';

/// Represents an [ChatClient] for an OpenAI [OpenAIClient] or [ChatClient].
class OpenAChatClient implements ChatClient {
  /// Initializes a new instance of the [OpenAIChatClient] class for the
  /// specified [ChatClient].
  ///
  /// [chatClient] The underlying client.
  OpenAChatClient(ChatClient chatClient) : _chatClient = Throw.ifNull(chatClient) {
    #pragma warning disable OPENAI001 // Endpoint and Model are experimental
        _metadata = new("openai", chatClient.endpoint, _chatClient.model);
  }

  static final Func4<ChatClient, Iterable<ChatMessage>, ChatCompletionOptions, RequestOptions, Future<ClientResult<ChatCompletion>>>? _completeChatAsync;

  static final Func4<ChatClient, Iterable<ChatMessage>, ChatCompletionOptions, RequestOptions, AsyncCollectionResult<StreamingChatCompletionUpdate>>? _completeChatStreamingAsync;

  /// Metadata about the client.
  final ChatClientMetadata _metadata;

  /// The underlying [ChatClient].
  final ChatClient _chatClient;

  /// Caller-registered policies applied to every [RequestOptions].
  final OpenARequestPolicies _requestPolicies;

  static final Regex _invalidAuthorNameRegex = new(InvalidAuthorNamePattern, RegexOptions.Compiled);

  Object? getService(Type serviceType, Object? serviceKey, ) {
    _ = Throw.ifNull(serviceType);
    return serviceKey != null ? null :
            serviceType == typeof(ChatClientMetadata) ? _metadata :
            serviceType == typeof(ChatClient) ? _chatClient :
            serviceType == typeof(OpenAIRequestPolicies) ? _requestPolicies :
            serviceType.isInstanceOfType(this) ? this :
            null;
  }

  @override
  Future<ChatResponse> getResponse(
    Iterable<ChatMessage> messages,
    {ChatOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    _ = Throw.ifNull(messages);
    OpenAIClientExtensions.addOpenAIApiType(OpenAIClientExtensions.openAIApiTypeChatCompletions);
    var openAIChatMessages = toOpenAIChatMessages(messages, options);
    var openAIOptions = toOpenAIOptions(options);
    var task = _completeChatAsync != null ?
            _completeChatAsync(
              _chatClient,
              openAIChatMessages,
              openAIOptions,
              cancellationToken.toRequestOptions(streaming: false, _requestPolicies),
            ) : 
            _chatClient.completeChatAsync(openAIChatMessages, openAIOptions, cancellationToken);
    var response = await task.configureAwait(false);
    return fromOpenAIChatCompletion(response.value, openAIOptions);
  }

  @override
  Stream<ChatResponseUpdate> getStreamingResponse(
    Iterable<ChatMessage> messages,
    {ChatOptions? options, CancellationToken? cancellationToken, },
  ) {
    _ = Throw.ifNull(messages);
    OpenAIClientExtensions.addOpenAIApiType(OpenAIClientExtensions.openAIApiTypeChatCompletions);
    var openAIChatMessages = toOpenAIChatMessages(messages, options);
    var openAIOptions = toOpenAIOptions(options);
    var chatCompletionUpdates = _completeChatStreamingAsync != null ?
            _completeChatStreamingAsync(
              _chatClient,
              openAIChatMessages,
              openAIOptions,
              cancellationToken.toRequestOptions(streaming: true, _requestPolicies),
            ) : 
            _chatClient.completeChatStreamingAsync(
              openAIChatMessages,
              openAIOptions,
              cancellationToken,
            );
    return fromOpenAIStreamingChatCompletionAsync(
      chatCompletionUpdates,
      openAIOptions,
      cancellationToken,
    );
  }

  void dispose() {

  }

  /// Converts an Extensions function to an OpenAI chat tool.
  static ChatTool toOpenAIChatTool(AFunctionDeclaration aiFunction, {ChatOptions? options, }) {
    var strict = OpenAIClientExtensions.hasStrict(aiFunction.additionalProperties) ??
            OpenAIClientExtensions.hasStrict(options?.additionalProperties);
    return ChatTool.createFunctionTool(
            aiFunction.name,
            aiFunction.description,
            OpenAIClientExtensions.toOpenAIFunctionParameters(aiFunction, strict),
            strict);
  }

  /// Converts an Extensions chat message enumerable to an OpenAI chat message
  /// enumerable.
  static Iterable<ChatMessage> toOpenAIChatMessages(
    Iterable<ChatMessage> inputs,
    ChatOptions? chatOptions,
  ) {
    if (chatOptions?.instructions is { } instructions && !string.isNullOrWhiteSpace(instructions)) {
      yield systemChatMessage(instructions);
    }
    for (final input in inputs) {
      if (input.rawRepresentation is ChatMessage) {
        final raw = input.rawRepresentation as ChatMessage;
        yield raw;
        continue;
      }
      if (input.role == ChatRole.system ||
                input.role == ChatRole.user ||
                input.role == OpenAIClientExtensions.chatRoleDeveloper) {
        var parts = toOpenAIChatContent(input.contents);
        var name = sanitizeAuthorName(input.authorName);
        yield input.role == ChatRole.system ? systemChatMessage(parts) :
        #pragma warning disable OPENAI001 // Developer role is experimental
                    input.role == OpenAIClientExtensions.chatRoleDeveloper ? developerChatMessage(parts) :
        #pragma warning restore OPENAI001
                    userChatMessage(parts);
      } else if (input.role == ChatRole.tool) {
        for (final item in input.contents) {
          if (item is FunctionResultContent) {
            final resultContent = item as FunctionResultContent;
            var result = resultContent.result as string;
            if (result == null && resultContent.result != null) {
              try {
                result = JsonSerializer.serialize(
                  resultContent.result,
                  AIJsonUtilities.defaultOptions.getTypeInfo(typeof(object)),
                );
              } catch (e, s) {
                if (e is NotSupportedException) {
                  final  = e as NotSupportedException;

                } else {
                  rethrow;
                }
              }
            }
            yield toolChatMessage(resultContent.callId, result ?? string.empty);
          }
        }
      } else if (input.role == ChatRole.assistant) {
        var contentParts = null;
        var toolCalls = null;
        var refusal = null;
        for (final content in input.contents) {
          switch (content) {
            case ErrorContent ec:
            refusal = ec.message;
            case FunctionCallContent fc:
            (toolCalls ??= []).add(
                                ChatToolCall.createFunctionToolCall(fc.callId, fc.name, new(JsonSerializer.serializeToUtf8Bytes(
                                    fc.arguments, AIJsonUtilities.defaultOptions.getTypeInfo(typeof(IDictionary<string, Object?>))))));
            default:
            if (toChatMessageContentPart(content) is { } part) {
              (contentParts ??= []).add(part);
            }
          }
        }
        AssistantChatMessage message;
        if (contentParts != null) {
          message = new(contentParts);
          if (toolCalls != null) {
            for (final toolCall in toolCalls) {
              message.toolCalls.add(toolCall);
            }
          }
        } else {
          message = toolCalls != null ?
                        new(toolCalls) :
                        new(ChatMessageContentPart.createTextPart(string.empty));
        }
        message.participantName = sanitizeAuthorName(input.authorName);
        message.refusal = refusal;
        yield message;
      }
    }
  }

  /// Converts a list of [AIContent] to a list of [ChatMessageContentPart].
  static List<ChatMessageContentPart> toOpenAIChatContent(Iterable<AContent> contents) {
    var parts = [];
    for (final content in contents) {
      if (content.rawRepresentation is ChatMessageContentPart) {
        final raw = content.rawRepresentation as ChatMessageContentPart;
        parts.add(raw);
      } else {
        if (toChatMessageContentPart(content) is { } part) {
          parts.add(part);
        }
      }
    }
    if (parts.count == 0) {
      parts.add(ChatMessageContentPart.createTextPart(string.empty));
    }
    return parts;
  }

  static ChatMessageContentPart? toChatMessageContentPart(AContent content) {
    switch (content) {
      case AIContent:
      return rawContentPart;
      case TextContent textContent:
      return ChatMessageContentPart.createTextPart(textContent.text);
      case UriContent uriContent:
      return ChatMessageContentPart.createImagePart(uriContent.uri, getImageDetail(content));
      case DataContent dataContent:
      return ChatMessageContentPart.createImagePart(
        BinaryData.fromBytes(dataContent.data),
        dataContent.mediaType,
        getImageDetail(content),
      );
      case DataContent dataContent:
      var audioData = BinaryData.fromBytes(dataContent.data);
      if (dataContent.mediaType.equals("audio/mpeg", StringComparison.ordinalIgnoreCase)) {
        return ChatMessageContentPart.createInputAudioPart(audioData, ChatInputAudioFormat.mp3);
      } else if (dataContent.mediaType.equals("audio/wav", StringComparison.ordinalIgnoreCase)) {
        return ChatMessageContentPart.createInputAudioPart(audioData, ChatInputAudioFormat.wav);
      }
      case DataContent dataContent:
      return ChatMessageContentPart.createFilePart(
        BinaryData.fromBytes(dataContent.data),
        dataContent.mediaType,
        dataContent.name ?? '${Guid.newGuid():N}.pdf',
      );
      case HostedFileContent fileContent:
      return ChatMessageContentPart.createFilePart(fileContent.fileId);
    }
    return null;
  }

  static ChatImageDetailLevel? getImageDetail(AContent content) {
    Object? value;
    if (content.additionalProperties?.tryGetValue("detail") is true) {
      return value switch
            {
                string (detailString) => chatImageDetailLevel(detailString),
                ChatImageDetailLevel (detail) => detail,
                (_) => null
            };
    }
    return null;
  }

  static Stream<ChatResponseUpdate> fromOpenAIStreamingChatCompletion(
    Stream<StreamingChatCompletionUpdate> updates,
    ChatCompletionOptions? options,
    CancellationToken cancellationToken,
  ) async  {
    var functionCallInfos = null;
    var streamedRole = null;
    var finishReason = null;
    var refusal = null;
    var responseId = null;
    var createdAt = null;
    var modelId = null;
    var serviceTier = null;
    var systemFingerprint = null;
    for (final update in updates.withCancellation(cancellationToken).configureAwait(false)) {
      // The role and finish reason may arrive during any update, but once they've arrived, the same value should be the same for all subsequent updates.
            streamedRole ??= update.role is ChatMessageRole role ? fromOpenAIChatRole(role) : null;
      finishReason ??= update.finishReason is OpenAI.chat.chatFinishReason reason ? fromOpenAIFinishReason(reason) : null;
      responseId ??= update.completionId;
      createdAt ??= update.createdAt;
      modelId ??= update.model;
      // Record the service tier and system fingerprint each once if not yet recorded.
            OpenAIClientExtensions.addOpenAIResponseAttributes(
                update.serviceTier?.toString(), update.systemFingerprint,
                ref serviceTier, ref systemFingerprint);
      var responseUpdate = new()
            {
                ResponseId = update.completionId,
                MessageId = update.completionId, // There is no per-message ID, but there's only one message per response, so use the response ID
                CreatedAt = update.createdAt,
                FinishReason = finishReason,
                ModelId = modelId,
                RawRepresentation = update,
                Role = streamedRole,
            };
      if (update.contentUpdate is { Count: > 0 }) {
        convertContentParts(update.contentUpdate, responseUpdate.contents);
      }
      string? reasoningText;
      if (tryGetReasoningDelta(update)) {
        responseUpdate.contents.add(textReasoningContent(reasoningText));
      }
      if (update.outputAudioUpdate is { } audioUpdate) {
        responseUpdate.contents.add(dataContent(audioUpdate.audioBytesUpdate.toMemory(), getOutputAudioMimeType(options))
                {
                    RawRepresentation = audioUpdate,
                });
      }
      if (update.refusalUpdate != null) {
        _ = (refusal ??= new()).append(update.refusalUpdate);
      }
      if (update.toolCallUpdates is { Count: > 0 } toolCallUpdates) {
        for (final toolCallUpdate in toolCallUpdates) {
          functionCallInfos ??= [];
          FunctionCallInfo existing;
          if (!functionCallInfos.tryGetValue(toolCallUpdate.index)) {
            functionCallInfos[toolCallUpdate.index] = existing = new();
          }
          existing.callId ??= toolCallUpdate.toolCallId;
          existing.name ??= toolCallUpdate.functionName;
          if (toolCallUpdate.functionArgumentsUpdate is { } argUpdate && !argUpdate.toMemory().isEmpty) {
            _ = (existing.arguments ??= new()).append(argUpdate.toString());
          }
        }
      }
      if (update.usage is ChatTokenUsage) {
        final tokenUsage = update.usage as ChatTokenUsage;
        responseUpdate.contents.add(usageContent(fromOpenAIUsage(tokenUsage))
                {
                    RawRepresentation = tokenUsage,
                });
      }
      yield responseUpdate;
    }
    if (functionCallInfos != null) {
      var responseUpdate = new()
            {
                ResponseId = responseId,
                MessageId = responseId, // There is no per-message ID, but there's only one message per response, so use the response ID
                CreatedAt = createdAt,
                FinishReason = finishReason,
                ModelId = modelId,
                Role = streamedRole,
            };
      for (final entry in functionCallInfos) {
        var fci = entry.value;
        if (!string.isNullOrWhiteSpace(fci.name)) {
          var callContent = OpenAIClientExtensions.parseCallContent(
                        fci.arguments?.toString() ?? string.empty,
                        fci.callId!,
                        fci.name!);
          responseUpdate.contents.add(callContent);
        }
      }
      if (refusal != null) {
        responseUpdate.contents.add(errorContent(refusal.toString()) { ErrorCode = "Refusal" });
      }
      yield responseUpdate;
    }
  }

  static String getOutputAudioMimeType(ChatCompletionOptions? options) {
    return options?.audioOptions?.outputAudioFormat.toString()?.toLowerInvariant() switch
        {
            "opus" => "audio/opus",
            "aac" => "audio/aac",
            "flac" => "audio/flac",
            "wav" => "audio/wav",
            "pcm" => "audio/pcm",
            "mp3" or (_) => "audio/mpeg",
        };
  }

  static ChatResponse fromOpenAIChatCompletion(
    ChatCompletion openAICompletion,
    ChatCompletionOptions? chatCompletionOptions,
  ) {
    _ = Throw.ifNull(openAICompletion);
    var returnMessage = new()
        {
            CreatedAt = openAICompletion.createdAt,
            MessageId = openAICompletion.id, // There's no per-message ID, so we use the same value as the response ID
            RawRepresentation = openAICompletion,
            Role = fromOpenAIChatRole(openAICompletion.role),
        };
    for (final contentPart in openAICompletion.content) {
      if (toAIContent(contentPart) is AContent) {
        final aiContent = toAIContent(contentPart) as AContent;
        returnMessage.contents.add(aiContent);
      }
    }
    string? reasoningText;
    if (tryGetReasoningMessage(openAICompletion)) {
      returnMessage.contents.add(textReasoningContent(reasoningText));
    }
    if (openAICompletion.outputAudio is ChatOutputAudio) {
      final audio = openAICompletion.outputAudio as ChatOutputAudio;
      returnMessage.contents.add(dataContent(audio.audioBytes.toMemory(), getOutputAudioMimeType(chatCompletionOptions))
            {
                RawRepresentation = audio,
            });
    }
    for (final toolCall in openAICompletion.toolCalls) {
      if (!string.isNullOrWhiteSpace(toolCall.functionName)) {
        var callContent = OpenAIClientExtensions.parseCallContent(
          toolCall.functionArguments,
          toolCall.id,
          toolCall.functionName,
        );
        callContent.rawRepresentation = toolCall;
        returnMessage.contents.add(callContent);
      }
    }
    if (openAICompletion.refusal is string) {
      final refusal = openAICompletion.refusal as string;
      returnMessage.contents.add(errorContent(refusal));
    }
    if (openAICompletion.annotations is { Count: > 0 }) {
      var annotationContent = returnMessage.contents.ofType<TextContent>().firstOrDefault();
      if (annotationContent == null) {
        annotationContent = new(null);
        returnMessage.contents.add(annotationContent);
      }
      for (final annotation in openAICompletion.annotations) {
        (annotationContent.annotations ??= []).add(citationAnnotation()],
                    Title = annotation.webResourceTitle,
                    Url = annotation.webResourceUri,
                });
    }
  }

  var response = chatResponse(returnMessage);
  OpenAIClientExtensions.addOpenAIResponseAttributes(
    openAICompletion.serviceTier?.toString(),
    openAICompletion.systemFingerprint,
  );
  if (openAICompletion.usage is ChatTokenUsage) {
    final tokenUsage = openAICompletion.usage as ChatTokenUsage;
    response.usage = fromOpenAIUsage(tokenUsage);
  }

  return response;
}
/// Converts an extensions options instance to an OpenAI options instance.
ChatCompletionOptions toOpenAIOptions(ChatOptions? options) {
if (options == null) {
  return new();
}
if (options.rawRepresentationFactory?.invoke(this) is! ChatCompletionOptions result) {
  result = new();
}
result.frequencyPenalty ??= options.frequencyPenalty;
result.maxOutputTokenCount ??= options.maxOutputTokens;
result.topP ??= options.topP;
result.presencePenalty ??= options.presencePenalty;
result.temperature ??= options.temperature;
#pragma warning disable OPENAI001 // Seed and ReasoningEffortLevel are experimental
        result.seed ??= options.seed;
result.reasoningEffortLevel ??= toOpenAIChatReasoningEffortLevel(options.reasoning?.effort);
#pragma warning restore OPENAI001

#pragma warning disable SCME0001 // JsonPatch is experimental
        OpenAIClientExtensions.patchModelIfNotSet(ref result.patch, options.modelId);
if (options.stopSequences is { Count: > 0 } stopSequences) {
  for (final stopSequence in stopSequences) {
    result.stopSequences.add(stopSequence);
  }
}
if (options.tools is { Count: > 0 } tools) {
  for (final tool in tools) {
    switch (tool) {
      case AIFunctionDeclaration af:
        result.tools.add(toOpenAIChatTool(af, options));
      case HostedWebSearchTool:
        #pragma warning disable OPENAI001 // WebSearchOptions is experimental
                        result.webSearchOptions ??= new();
    }
  }

  if (result.tools.count > 0) {
    result.allowParallelToolCalls ??= options.allowMultipleToolCalls;
  }

  if (result.toolChoice == null && result.tools.count > 0) {
    switch (options.toolMode) {
      case NoneChatToolMode:
        result.toolChoice = ChatToolChoice.createNoneChoice();
      case AutoChatToolMode || null:
        result.toolChoice = ChatToolChoice.createAutoChoice();
      case RequiredChatToolMode required:
        result.toolChoice = required.requiredFunctionName == null ?
                            ChatToolChoice.createRequiredChoice() :
                            ChatToolChoice.createFunctionChoice(required.requiredFunctionName);
    }
  }
}
result.responseFormat ??= toOpenAIChatResponseFormat(options.responseFormat, options);
return result;
 }
static ChatResponseFormat? toOpenAIChatResponseFormat(
  ChatResponseFormat? format,
  ChatOptions? options,
) {
return format switch
        {
            (ChatResponseFormatText) => OpenAI.chat.chatResponseFormat.createTextFormat(),

#pragma warning disable OPENAI001 // OpenAIJsonContext is marked as experimental since it relies on source-generated serializers
            ChatResponseFormatJson jsonFormat when OpenAIClientExtensions.strictSchemaTransformCache.getOrCreateTransformedSchema(jsonFormat) is { } (jsonSchema) =>
                 OpenAI.chat.chatResponseFormat.createJsonSchemaFormat(
                    jsonFormat.schemaName ?? "json_schema",
                    BinaryData.fromBytes(JsonSerializer.serializeToUtf8Bytes(jsonSchema, OpenAIJsonContext.defaultValue.jsonElement)),
                    jsonFormat.schemaDescription,
                    OpenAIClientExtensions.hasStrict(options?.additionalProperties)),
#pragma warning restore OPENAI001

            (ChatResponseFormatJson) => OpenAI.chat.chatResponseFormat.createJsonObjectFormat(),

            (_) => null
        };
 }
static ChatReasoningEffortLevel? toOpenAIChatReasoningEffortLevel(ReasoningEffort? effort) {
return effort switch
        {
            ReasoningEffort.none => ChatReasoningEffortLevel.none,
            ReasoningEffort.low => ChatReasoningEffortLevel.low,
            ReasoningEffort.medium => ChatReasoningEffortLevel.medium,
            ReasoningEffort.high => ChatReasoningEffortLevel.high,
            ReasoningEffort.extraHigh => chatReasoningEffortLevel("xhigh"),
            (_) => (ChatReasoningEffortLevel?)null,
        };
 }
static UsageDetails fromOpenAIUsage(ChatTokenUsage tokenUsage) {
var destination = usageDetails();
var counts = destination.additionalCounts;
if (tokenUsage.inputTokenDetails is ChatInputTokenUsageDetails) {
    final inputDetails = tokenUsage.inputTokenDetails as ChatInputTokenUsageDetails;
    var InputDetails = nameof(ChatTokenUsage.inputTokenDetails);
    counts.add(
      '${InputDetails}.${nameof(ChatInputTokenUsageDetails.audioTokenCount)}',
      inputDetails.audioTokenCount,
    );
  }

if (tokenUsage.outputTokenDetails is ChatOutputTokenUsageDetails) {
    final outputDetails = tokenUsage.outputTokenDetails as ChatOutputTokenUsageDetails;
    var OutputDetails = nameof(ChatTokenUsage.outputTokenDetails);
    counts.add(
      '${OutputDetails}.${nameof(ChatOutputTokenUsageDetails.audioTokenCount)}',
      outputDetails.audioTokenCount,
    );
    #pragma warning disable OPENAI001 // AcceptedPredictionTokenCount and RejectedPredictionTokenCount are experimental
            counts.add(
              '${OutputDetails}.${nameof(ChatOutputTokenUsageDetails.acceptedPredictionTokenCount)}',
              outputDetails.acceptedPredictionTokenCount,
            );
    counts.add(
      '${OutputDetails}.${nameof(ChatOutputTokenUsageDetails.rejectedPredictionTokenCount)}',
      outputDetails.rejectedPredictionTokenCount,
    );
  }

return destination;
 }
/// Converts an OpenAI role to an Extensions role.
static ChatRole fromOpenAIChatRole(ChatMessageRole role) {
return role switch
        {
            ChatMessageRole.system => ChatRole.system,
            ChatMessageRole.user => ChatRole.user,
            ChatMessageRole.assistant => ChatRole.assistant,
            ChatMessageRole.tool => ChatRole.tool,
#pragma warning disable OPENAI001 // Developer role is experimental
            ChatMessageRole.developer => OpenAIClientExtensions.chatRoleDeveloper,
#pragma warning restore OPENAI001
            (_) => chatRole(role.toString()),
        };
 }
/// Creates [AIContent]s from [ChatMessageContent].
///
/// [content] The content parts to convert into a content.
///
/// [results] The result collection into which to write the resulting content.
static void convertContentParts(ChatMessageContent content, List<AContent> results, ) {
for (final contentPart in content) {
  if (toAIContent(contentPart) is { } aiContent) {
    results.add(aiContent);
  }
}
 }
/// Creates an [AIContent] from a [ChatMessageContentPart].
///
/// Returns: The constructed [AIContent], or `null` if the content part could
/// not be converted.
///
/// [contentPart] The content part to convert into a content.
static AContent? toAIContent(ChatMessageContentPart contentPart) {
var aiContent = null;
switch (contentPart.kind) {
  case ChatMessageContentPartKind.text:
    aiContent = textContent(contentPart.text);
  case ChatMessageContentPartKind.image:
    aiContent =
                    contentPart.imageUri != null ? uriContent(
                      contentPart.imageUri,
                      OpenAIClientExtensions.imageUriToMediaType(contentPart.imageUri),
                    ) : 
                    contentPart.imageBytes != null ? dataContent(
                      contentPart.imageBytes.toMemory(),
                      contentPart.imageBytesMediaType,
                    ) : 
                    null;
    if (aiContent != null && contentPart.imageDetailLevel?.toString() is string) {
        final detail = aiContent != null && contentPart.imageDetailLevel?.toString() as string;
        (aiContent.additionalProperties ??= [])[nameof(contentPart.imageDetailLevel)] = detail;
      }
  case ChatMessageContentPartKind.file:
    aiContent =
                    contentPart.fileId != null ? hostedFileContent(contentPart.fileId) :
                    contentPart.fileBytes != null ? dataContent(
                      contentPart.fileBytes.toMemory(),
                      contentPart.fileBytesMediaType,
                    ) { Name = contentPart.filename } :
                    null;
}
if (aiContent != null) {
  if (contentPart.refusal is string) {
      final refusal = contentPart.refusal as string;
      (aiContent.additionalProperties ??= [])[nameof(contentPart.refusal)] = refusal;
    }
  aiContent.rawRepresentation = contentPart;
}
return aiContent;
 }
/// Converts an OpenAI finish reason to an Extensions finish reason.
static ChatFinishReason? fromOpenAIFinishReason(ChatFinishReason? finishReason) {
return finishReason?.toString() is! String s ? null :
        finishReason switch
        {
            OpenAI.chat.chatFinishReason.stop => ChatFinishReason.stop,
            OpenAI.chat.chatFinishReason.length => ChatFinishReason.length,
            OpenAI.chat.chatFinishReason.contentFilter => ChatFinishReason.contentFilter,
            OpenAI.chat.chatFinishReason.toolCalls or OpenAI.chat.chatFinishReason.functionCall => ChatFinishReason.toolCalls,
            (_) => chatFinishReason(s),
        };
 }
/// Sanitizes the author name to be appropriate for including as an OpenAI
/// participant name.
static String? sanitizeAuthorName(String? name) {
if (name != null) {
  var MaxLength = 64;
  name = invalidAuthorNameRegex().replace(name, string.empty);
  if (name.length == 0) {
    name = null;
  } else if (name.length > MaxLength) {
    name = name.substring(0, MaxLength);
  }
}
return name;
 }
/// Tries to extract reasoning text from a streaming chat completion update's
/// Patch.
static (bool, String??) tryGetReasoningDelta(StreamingChatCompletionUpdate update) {
// TODO(transpiler): implement out-param body
throw UnimplementedError();
 }
/// Tries to extract reasoning text from a non-streaming chat completion's
/// Patch.
static (bool, String??) tryGetReasoningMessage(ChatCompletion completion) {
// TODO(transpiler): implement out-param body
throw UnimplementedError();
 }
static Regex invalidAuthorNameRegex() {
return _invalidAuthorNameRegex;
 }
 }
/// POCO representing function calling info. Used to concatenation information
/// for a single function call from across multiple streaming updates.
class FunctionCallInfo {
  FunctionCallInfo();

  String? callId;

  String? name;

  StringBuffer? arguments;

}
