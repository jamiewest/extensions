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
import '../abstractions/chat_completion/reasoning_options.dart';
import '../abstractions/chat_completion/reasoning_output.dart';
import '../abstractions/chat_completion/required_chat_tool_mode.dart';
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
import '../abstractions/contents/text_span_annotated_region.dart';
import '../abstractions/contents/tool_approval_request_content.dart';
import '../abstractions/contents/tool_approval_response_content.dart';
import '../abstractions/contents/tool_call_content.dart';
import '../abstractions/contents/tool_result_content.dart';
import '../abstractions/contents/uri_content.dart';
import '../abstractions/contents/usage_content.dart';
import '../abstractions/contents/web_search_tool_call_content.dart';
import '../abstractions/contents/web_search_tool_result_content.dart';
import '../abstractions/functions/ai_function_declaration.dart';
import '../abstractions/hosted_mcp_server_tool_always_require_approval_mode.dart';
import '../abstractions/hosted_mcp_server_tool_never_require_approval_mode.dart';
import '../abstractions/hosted_mcp_server_tool_require_specific_approval_mode.dart';
import '../abstractions/tools/ai_tool.dart';
import '../abstractions/tools/hosted_code_interpreter_tool.dart';
import '../abstractions/tools/hosted_file_search_tool.dart';
import '../abstractions/tools/hosted_image_generation_tool.dart';
import '../abstractions/tools/hosted_mcp_server_tool.dart';
import '../abstractions/tools/hosted_tool_search_tool.dart';
import '../abstractions/tools/hosted_web_search_tool.dart';
import '../abstractions/usage_details.dart';
import '../open_telemetry_consts.dart';
import 'open_ai_client_extensions.dart';
import 'open_ai_json_context.dart';
import 'open_ai_request_policies.dart';
import 'responses_client_continuation_token.dart';

/// Represents an [ChatClient] for an [ResponsesClient].
class OpenAResponsesChatClient implements ChatClient {
  /// Initializes a new instance of the [OpenAIResponsesChatClient] class for
  /// the specified [ResponsesClient].
  ///
  /// [responseClient] The underlying client.
  ///
  /// [defaultModelId] The default model ID to use for the chat client.
  OpenAResponsesChatClient(
    ResponsesClient responseClient,
    String? defaultModelId,
  ) :
      _responseClient = responseClient,
      _defaultModelId = defaultModelId,
      _metadata = new("openai", responseClient.endpoint, defaultModelId) {
    _ = Throw.ifNull(responseClient);
  }

  static final Func3<ResponsesClient, CreateResponseOptions, RequestOptions, AsyncCollectionResult<StreamingResponseUpdate>>? _createResponseStreamingAsync;

  static final Func3<ResponsesClient, GetResponseOptions, RequestOptions, AsyncCollectionResult<StreamingResponseUpdate>>? _getResponseStreamingAsync;

  /// Metadata about the client.
  final ChatClientMetadata _metadata;

  /// The underlying [ResponsesClient].
  final ResponsesClient _responseClient;

  /// The default model ID to use for the chat client.
  final String? _defaultModelId;

  /// Caller-registered policies applied to every [RequestOptions].
  final OpenARequestPolicies _requestPolicies;

  Object? getService(Type serviceType, Object? serviceKey, ) {
    _ = Throw.ifNull(serviceType);
    return serviceKey != null ? null :
            serviceType == typeof(ChatClientMetadata) ? _metadata :
            serviceType == typeof(ResponsesClient) ? _responseClient :
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
    OpenAIClientExtensions.addOpenAIApiType(OpenAIClientExtensions.openAIApiTypeResponses);
    var openAIOptions = asCreateResponseOptions(options, out string? openAIConversationId);
    if (getContinuationToken(messages, options) is { } token) {
      var getTask = _responseClient.getResponseAsync(
        token.responseId,
        include: null,
        stream: null,
        startingAfter: null,
        includeObfuscation: null,
        cancellationToken.toRequestOptions(streaming: false, _requestPolicies),
      );
      var response = (ResponseResult)await getTask.configureAwait(false);
      return fromOpenAIResponse(response, openAIOptions, openAIConversationId);
    }
    for (final responseItem in toOpenAIResponseItems(messages, options)) {
      openAIOptions.inputItems.add(responseItem);
    }
    var createTask = _responseClient.createResponseAsync(
      (BinaryContent)openAIOptions,
      cancellationToken.toRequestOptions(streaming: false, _requestPolicies),
    );
    var openAIResponsesResult = (ResponseResult)await createTask.configureAwait(false);
    return fromOpenAIResponse(openAIResponsesResult, openAIOptions, openAIConversationId);
  }

  static ChatResponse fromOpenAIResponse(
    ResponseResult responseResult,
    CreateResponseOptions? openAIOptions,
    String? conversationId,
  ) {
    OpenAIClientExtensions.addOpenAIResponseAttributes(
      responseResult.serviceTier?.toString(),
      systemFingerprint: null,
    );
    var response = new()
        {
            ConversationId = isStoredOutputDisabled(
              openAIOptions,
              responseResult,
            ) ? null : (conversationId ?? responseResult.id),
            CreatedAt = responseResult.createdAt,
            ContinuationToken = createContinuationToken(responseResult),
            FinishReason = asFinishReason(responseResult.incompleteStatusDetails?.reason),
            ModelId = responseResult.model,
            RawRepresentation = responseResult,
            ResponseId = responseResult.id,
            Usage = toUsageDetails(responseResult),
        };
    if (!string.isNullOrEmpty(responseResult.endUserId)) {
      (response.additionalProperties ??= [])[nameof(responseResult.endUserId)] = responseResult.endUserId;
    }
    if (responseResult.error != null) {
      (response.additionalProperties ??= [])[nameof(responseResult.error)] = responseResult.error;
    }
    if (responseResult.outputItems != null) {
      response.messages = [.. toChatMessages(responseResult.outputItems, openAIOptions)];
      if (response.messages.lastOrDefault() is { } lastMessage && responseResult.error is { } error) {
        lastMessage.contents.add(errorContent(error.message));
      }
      for (final message in response.messages) {
        message.createdAt ??= responseResult.createdAt;
      }
    }
    if (responseResult.safetyIdentifier != null) {
      (response.additionalProperties ??= [])[nameof(responseResult.safetyIdentifier)] = responseResult.safetyIdentifier;
    }
    return response;
  }

  static Iterable<ChatMessage> toChatMessages(
    Iterable<ResponseItem> items,
    {CreateResponseOptions? options, },
  ) {
    var message = null;
    var mcpApprovalRequests = null;
    for (final outputItem in items) {
      message ??= new(ChatRole.assistant, (string?)null);
      switch (outputItem) {
        case MessageResponseItem messageItem:
        if (message.messageId != null && message.messageId != messageItem.id) {
          yield message;
          message = chatMessage();
        }
        message.messageId = messageItem.id;
        message.rawRepresentation = messageItem;
        message.role = asChatRole(messageItem.role);
        ((List<AContent>)message.contents).addRange(toAIContents(messageItem.content));
        case ReasoningResponseItem reasoningItem:
        message.contents.add(textReasoningContent(reasoningItem.getSummaryText())
                    {
                        ProtectedData = reasoningItem.encryptedContent,
                        RawRepresentation = outputItem,
                    });
        case FunctionCallResponseItem functionCall:
        var fcc = OpenAIClientExtensions.parseCallContent(
          functionCall.functionArguments,
          functionCall.callId,
          functionCall.functionName,
        );
        fcc.rawRepresentation = outputItem;
        message.contents.add(fcc);
        case FunctionCallOutputResponseItem functionCallOutputItem:
        message.contents.add(functionResultContent(functionCallOutputItem.callId, functionCallOutputItem.functionOutput));
        case McpToolCallItem mtci:
        addMcpToolCallContent(mtci, message.contents);
        case McpToolCallApprovalRequestItem mtcari:
        var approvalRequest = toolApprovalRequestContent(
          mtcari.id,
          mcpServerToolCallContent(mtcari.id, mtcari.toolName, mtcari.serverLabel),
        )
                    {
                        RawRepresentation = mtcari,
                    };
        // Store for correlation with responses.
                    (mcpApprovalRequests ??= new())[mtcari.id] = approvalRequest;
        message.contents.add(approvalRequest);
        case McpToolCallApprovalResponseItem mtcari:
        _ = mcpApprovalRequests.remove(mtcari.approvalRequestId);
        // Correlate with the original request to reuse its ToolCall.
                    // McpToolCallApprovalResponseItem without a correlated request falls through to default.
                    message.contents.add(toolApprovalResponseContent(
                        mtcari.approvalRequestId,
                        mtcari.approved,
                        request.toolCall));
        case CodeInterpreterCallResponseItem cicri:
        message.contents.add(codeInterpreterToolCallContent(cicri.id));
        message.contents.add(createCodeInterpreterResultContent(cicri));
        case ImageGenerationCallResponseItem imageGenItem:
        addImageGenerationContents(imageGenItem, options, message.contents);
        case WebSearchCallResponseItem wscri:
        message.contents.add(webSearchToolCallContent(wscri.id));
        message.contents.add(webSearchToolResultContent(wscri.id));
        case FileSearchCallResponseItem:
        message.contents.add(toolCallContent(outputItem.id));
        message.contents.add(toolResultContent(outputItem.id));
        case ComputerCallResponseItem computerCall:
        message.contents.add(toolCallContent(computerCall.callId));
        case ComputerCallOutputResponseItem computerCallOutput:
        message.contents.add(toolResultContent(computerCallOutput.callId));
        case ApplyPatchCallItem patchCall:
        message.contents.add(toolCallContent(patchCall.callId));
        case ApplyPatchCallOutputItem patchCallOutput:
        message.contents.add(toolResultContent(patchCallOutput.callId));
        default:
        message.contents.add(new() { RawRepresentation = outputItem });
      }
    }
    if (message != null) {
      yield message;
    }
  }

  @override
  Stream<ChatResponseUpdate> getStreamingResponse(
    Iterable<ChatMessage> messages,
    {ChatOptions? options, CancellationToken? cancellationToken, },
  ) {
    _ = Throw.ifNull(messages);
    OpenAIClientExtensions.addOpenAIApiType(OpenAIClientExtensions.openAIApiTypeResponses);
    var openAIOptions = asCreateResponseOptions(options, out string? openAIConversationId);
    openAIOptions.streamingEnabled = true;
    if (getContinuationToken(messages, options) is { } token) {
      var getOptions = new(token.responseId) { StartingAfter = token.sequenceNumber, StreamingEnabled = true };
      Debug.assertValue(
        _getResponseStreamingAsync != null,
        'Unable to find ${nameof(_getResponseStreamingAsync)} method',
      );
      var getUpdates = _getResponseStreamingAsync != null ?
                _getResponseStreamingAsync(
                  _responseClient,
                  getOptions,
                  cancellationToken.toRequestOptions(streaming: true, _requestPolicies),
                ) : 
                _responseClient.getResponseStreamingAsync(getOptions, cancellationToken);
      return fromOpenAIStreamingResponseUpdatesAsync(
        getUpdates,
        openAIOptions,
        openAIConversationId,
        token.responseId,
        cancellationToken,
      );
    }
    for (final responseItem in toOpenAIResponseItems(messages, options)) {
      openAIOptions.inputItems.add(responseItem);
    }
    Debug.assertValue(
      _createResponseStreamingAsync != null,
      'Unable to find ${nameof(_createResponseStreamingAsync)} method',
    );
    var createUpdates = _createResponseStreamingAsync != null ?
            _createResponseStreamingAsync(
              _responseClient,
              openAIOptions,
              cancellationToken.toRequestOptions(streaming: true, _requestPolicies),
            ) : 
            _responseClient.createResponseStreamingAsync(openAIOptions, cancellationToken);
    return fromOpenAIStreamingResponseUpdatesAsync(
      createUpdates,
      openAIOptions,
      openAIConversationId,
      cancellationToken: cancellationToken,
    );
  }

  static Stream<ChatResponseUpdate> fromOpenAIStreamingResponseUpdates(
    Stream<StreamingResponseUpdate> streamingResponseUpdates,
    CreateResponseOptions? options,
    String? conversationId,
    {String? resumeResponseId, CancellationToken? cancellationToken, },
  ) async  {
    var createdAt = null;
    var responseId = resumeResponseId;
    var modelId = null;
    var lastMessageId = null;
    var lastRole = null;
    var anyFunctions = false;
    var storedOutputDisabled = false;
    var serviceTier = null;
    var systemFingerprint = null;
    var latestResponseStatus = null;
    var mcpApprovalRequests = null;
    updateConversationId(resumeResponseId);
    for (final streamingUpdate in streamingResponseUpdates.withCancellation(cancellationToken).configureAwait(false)) {
      /* TODO: unsupported node kind "unknown" */
      // // Create an update populated with the current state of the response.
      //             ChatResponseUpdate CreateUpdate(AIContent? content = null) =>
      //                 new(lastRole, content is not null ? [content] : null)
      //                 {
        //                     ContinuationToken = CreateContinuationToken(
        //                         responseId!,
        //                         latestResponseStatus,
        //                         options?.BackgroundModeEnabled,
        //                         streamingUpdate.SequenceNumber),
        //                     ConversationId = conversationId,
        //                     CreatedAt = createdAt,
        //                     MessageId = lastMessageId,
        //                     ModelId = modelId,
        //                     RawRepresentation = streamingUpdate,
        //                     ResponseId = responseId,
        //                 };
      switch (streamingUpdate) {
        case StreamingResponseCreatedUpdate createdUpdate:
        createdAt = createdUpdate.response.createdAt;
        responseId = createdUpdate.response.id;
        updateConversationId(responseId, createdUpdate.response);
        modelId = createdUpdate.response.model;
        latestResponseStatus = createdUpdate.response.status;
        /* TODO: unsupported node kind "unknown" */
        // goto default;
        case StreamingResponseQueuedUpdate queuedUpdate:
        createdAt = queuedUpdate.response.createdAt;
        responseId = queuedUpdate.response.id;
        updateConversationId(responseId, queuedUpdate.response);
        modelId = queuedUpdate.response.model;
        latestResponseStatus = queuedUpdate.response.status;
        /* TODO: unsupported node kind "unknown" */
        // goto default;
        case StreamingResponseInProgressUpdate inProgressUpdate:
        createdAt = inProgressUpdate.response.createdAt;
        responseId = inProgressUpdate.response.id;
        updateConversationId(responseId, inProgressUpdate.response);
        modelId = inProgressUpdate.response.model;
        latestResponseStatus = inProgressUpdate.response.status;
        /* TODO: unsupported node kind "unknown" */
        // goto default;
        case StreamingResponseIncompleteUpdate incompleteUpdate:
        createdAt = incompleteUpdate.response.createdAt;
        responseId = incompleteUpdate.response.id;
        updateConversationId(responseId, incompleteUpdate.response);
        modelId = incompleteUpdate.response.model;
        latestResponseStatus = incompleteUpdate.response.status;
        /* TODO: unsupported node kind "unknown" */
        // goto default;
        case StreamingResponseFailedUpdate failedUpdate:
        createdAt = failedUpdate.response.createdAt;
        responseId = failedUpdate.response.id;
        updateConversationId(responseId, failedUpdate.response);
        modelId = failedUpdate.response.model;
        latestResponseStatus = failedUpdate.response.status;
        /* TODO: unsupported node kind "unknown" */
        // goto default;
        case StreamingResponseCompletedUpdate completedUpdate:
        {
          createdAt = completedUpdate.response.createdAt;
          responseId = completedUpdate.response.id;
          updateConversationId(responseId, completedUpdate.response);
          modelId = completedUpdate.response.model;
          latestResponseStatus = completedUpdate.response?.status;
          var update = createUpdate(toUsageDetails(completedUpdate.response) is { } usage ? usageContent(usage) : null);
          update.finishReason =
                        asFinishReason(completedUpdate.response?.incompleteStatusDetails?.reason) ??
                        (anyFunctions ? ChatFinishReason.toolCalls :
                        ChatFinishReason.stop);
          yield update;
          break;
        }
        case StreamingResponseOutputItemAddedUpdate outputItemAddedUpdate:
        switch (outputItemAddedUpdate.item) {
          case MessageResponseItem mri:
          lastMessageId = outputItemAddedUpdate.item.id;
          lastRole = asChatRole(mri.role);
          case FunctionCallResponseItem fcri:
          anyFunctions = true;
          lastRole = ChatRole.assistant;
        }
        /* TODO: unsupported node kind "unknown" */
        // goto default;
        case StreamingResponseOutputTextDeltaUpdate outputTextDeltaUpdate:
        yield createUpdate(textContent(outputTextDeltaUpdate.delta));
        case StreamingResponseReasoningSummaryTextDeltaUpdate reasoningSummaryTextDeltaUpdate:
        yield createUpdate(textReasoningContent(reasoningSummaryTextDeltaUpdate.delta));
        case StreamingResponseReasoningTextDeltaUpdate reasoningTextDeltaUpdate:
        yield createUpdate(textReasoningContent(reasoningTextDeltaUpdate.delta));
        case StreamingResponseImageGenerationCallInProgressUpdate imageGenInProgress:
        yield createUpdate(imageGenerationToolCallContent(imageGenInProgress.itemId));
        case StreamingResponseImageGenerationCallPartialImageUpdate streamingImageGenUpdate:
        yield createUpdate(getImageGenerationResult(streamingImageGenUpdate, options));
        case StreamingResponseCodeInterpreterCallCodeDeltaUpdate codeInterpreterDeltaUpdate:
        yield createUpdate(codeInterpreterToolCallContent(codeInterpreterDeltaUpdate.itemId));
        case StreamingResponseWebSearchCallInProgressUpdate webSearchInProgressUpdate:
        yield createUpdate(webSearchToolCallContent(webSearchInProgressUpdate.itemId));
        case StreamingResponseOutputItemDoneUpdate outputItemDoneUpdate:
        switch (outputItemDoneUpdate.item) {
          case FunctionCallResponseItem fcri:
          yield createUpdate(OpenAIClientExtensions.parseCallContent(fcri.functionArguments.toString(), fcri.callId, fcri.functionName));
          case McpToolCallItem mtci:
          var mcpUpdate = createUpdate();
          addMcpToolCallContent(mtci, mcpUpdate.contents);
          yield mcpUpdate;
          case McpToolCallApprovalRequestItem mtcari:
          var streamApprovalRequest = toolApprovalRequestContent(
            mtcari.id,
            mcpServerToolCallContent(mtcari.id, mtcari.toolName, mtcari.serverLabel),
          )
                            {
                                RawRepresentation = mtcari,
                            };
          // Store for correlation with responses.
                            (mcpApprovalRequests ??= new())[mtcari.id] = streamApprovalRequest;
          yield createUpdate(streamApprovalRequest);
          case McpToolCallApprovalResponseItem mtcari:
          _ = mcpApprovalRequests.remove(mtcari.approvalRequestId);
          yield createUpdate(toolApprovalResponseContent(
                                mtcari.approvalRequestId,
                                mtcari.approved,
                                request.toolCall));
          case FunctionCallOutputResponseItem functionCallOutputItem:
          lastRole ??= ChatRole.assistant;
          yield createUpdate(functionResultContent(functionCallOutputItem.callId, functionCallOutputItem.functionOutput));
          case CodeInterpreterCallResponseItem cicri:
          yield createUpdate(createCodeInterpreterResultContent(cicri));
          case WebSearchCallResponseItem wscri:
          yield createUpdate(webSearchToolCallContent(wscri.id));
          yield createUpdate(webSearchToolResultContent(wscri.id));
          case MessageResponseItem mri:
          var annotatedContent = new();
          for (final c in mriContent) {
            populateAnnotations(c, annotatedContent);
          }
          yield createUpdate(annotatedContent);
          case ReasoningResponseItem rri:
          yield createUpdate(textReasoningContent(null));
          case MessageResponseItem or ReasoningResponseItem or ImageGenerationCallResponseItem:
          yield createUpdate();
          case FileSearchCallResponseItem:
          var toolCallUpdate = createUpdate(toolCallContent(outputItemDoneUpdate.item.id));
          toolCallUpdate.contents.add(toolResultContent(outputItemDoneUpdate.item.id));
          yield toolCallUpdate;
          case ComputerCallResponseItem computerCall:
          yield createUpdate(toolCallContent(computerCall.callId));
          case ComputerCallOutputResponseItem computerCallOutput:
          yield createUpdate(toolResultContent(computerCallOutput.callId));
          default:
          yield createUpdate(aContent());
        }
        case StreamingResponseErrorUpdate errorUpdate:
        var errorMessage = errorUpdate.message;
        var errorCode = errorUpdate.code;
        var errorParam = errorUpdate.param;
        {
          if (string.isNullOrEmpty(errorMessage)) {
            _ = errorUpdate.patch.tryGetValue("$.error.message"u8, out errorMessage);
          }
          if (string.isNullOrEmpty(errorCode)) {
            _ = errorUpdate.patch.tryGetValue("$.error.code"u8, out errorCode);
          }
          if (string.isNullOrEmpty(errorParam)) {
            _ = errorUpdate.patch.tryGetValue("$.error.param"u8, out errorParam);
          }
        }
        yield createUpdate(errorContent(errorMessage));
        case StreamingResponseRefusalDoneUpdate refusalDone:
        yield createUpdate(errorContent(refusalDone.refusal));
        default:
        yield createUpdate();
      }
    }
    /* TODO: unsupported node kind "unknown" */
    // void UpdateConversationId(string? id, ResponseResult? response = null)
    //         {
      //             // Record the service tier and system fingerprint each once if not yet recorded.
      //             OpenAIClientExtensions.AddOpenAIResponseAttributes(
      //                 response?.ServiceTier?.ToString(), systemFingerprint: null,
      //                 ref serviceTier, ref systemFingerprint);
      //
      //             storedOutputDisabled |= IsStoredOutputDisabled(options, response);
      //             if (storedOutputDisabled)
      //             {
        //                 conversationId = null;
        //             }
      //             else
      //             {
        //                 conversationId ??= id;
        //             }
      //         }
  }

  void dispose() {

  }

  /// Determines whether stored output is disabled, either via the request
  /// options or by checking the actual response's "store" field via Patch.
  static bool isStoredOutputDisabled(CreateResponseOptions? options, ResponseResult? response, ) {
    return options?.storedOutputEnabled is false ||
        (response != null && response.patch.tryGetValue("$.store"u8, out bool store) && !store);
  }

  static ResponseTool? toResponseTool(
    ChatOptions? options,
    {ATool? tool, ToolSearchLookup? toolSearchLookup, AFunctionDeclaration? aiFunction, },
  ) {
    switch (tool) {
      case ResponseToolAITool rtat:
      return rtat.tool;
      case AIFunctionDeclaration aiFunction:
      var functionTool = toResponseTool(aiFunction, options);
      if ((toolSearchLookup ??= ToolSearchLookup.create(options?.tools)).isDeferred(aiFunction.name)) {
        functionTool.patch.setValue("$.defer_loading"u8, "true"u8);
      }
      return functionTool;
      case HostedToolSearchTool:
      return ModelReaderWriter.read<ResponseTool>(
        BinaryData.fromString("""{"type": "tool_search"}"""),
        ModelReaderWriterOptions.json,
        OpenAIContext.defaultValue,
      ) !;
      case HostedWebSearchTool webSearchTool:
      return webSearchTool();
      case HostedFileSearchTool fileSearchTool:
      return fileSearchTool(fileSearchTool.inputs?.ofType<HostedVectorStoreContent>().select((c) => c.vectorStoreId) ?? [])
                {
                    Filters = fileSearchTool.getProperty<BinaryData?>(nameof(FileSearchTool.filters)),
                    MaxResultCount = fileSearchTool.maximumResultCount,
                    RankingOptions = fileSearchTool.getProperty<FileSearchToolRankingOptions?>(nameof(FileSearchTool.rankingOptions)),
                };
      case HostedCodeInterpreterTool codeTool:
      return codeInterpreterTool(
                    new(codeTool.inputs?.ofType<HostedFileContent>().select((f) => f.fileId).toList() is { Count: > 0 } ids ?
                        CodeInterpreterToolContainerConfiguration.createAutomaticContainerConfiguration(ids) :
                        new()));
      case HostedImageGenerationTool imageGenerationTool:
      var igo = imageGenerationTool.options;
      return imageGenerationTool() mediaType ?
                        mediaType switch
                        {
                            "image/png" => ImageGenerationToolOutputFileFormat.png,
                            "image/jpeg" => ImageGenerationToolOutputFileFormat.jpeg,
                            "image/webp" => ImageGenerationToolOutputFileFormat.webp,
                            (_) => null,
                        } :
                        null,
                    PartialImageCount = igo?.streamingCount,
                    Quality = imageGenerationTool.getProperty<ImageGenerationToolQuality?>(nameof(ImageGenerationTool.quality)),
                    Size = igo?.imageSize is { } size ?
                        imageGenerationToolSize(size.width, size.height) :
                        null,
                };
    case HostedMcpServerTool mcpTool:
    var isUrl = Uri.tryCreate(mcpTool.serverAddress, UriKind.absolute, out Uri? serverAddressUrl);
    var responsesMcpTool = isUrl ?
                    mcpTool(mcpTool.serverName, serverAddressUrl!) :
                    mcpTool(mcpTool.serverName, mcpToolConnectorId(mcpTool.serverAddress));
    responsesMcpTool.serverDescription = mcpTool.serverDescription;
    if (isUrl) {
      if (mcpTool.headers is { Count: > 0 }) {
        responsesMcpTool.headers = mcpTool.headers;
      }
    } else {
      String? authHeader;
      if (mcpTool.headers?.tryGetValue("Authorization") is true &&
                        authHeader.asSpan().trim() is { Length: > 0 } trimmedAuthHeader &&
                        trimmedAuthHeader.startsWith(
                          "Bearer ",
                          StringComparison.ordinalIgnoreCase,
                        ) ) {
        responsesMcpTool.authorizationToken = trimmedAuthHeader.slice("Bearer ".length).trimStart().toString();
      }
    }
    if (mcpTool.allowedTools != null) {
      responsesMcpTool.allowedTools = new();
      addAllMcpFilters(mcpTool.allowedTools, responsesMcpTool.allowedTools);
    }
    switch (mcpTool.approvalMode) {
      case HostedMcpServerToolAlwaysRequireApprovalMode:
        responsesMcpTool.toolCallApprovalPolicy = mcpToolCallApprovalPolicy(GlobalMcpToolCallApprovalPolicy.alwaysRequireApproval);
      case HostedMcpServerToolNeverRequireApprovalMode:
        responsesMcpTool.toolCallApprovalPolicy = mcpToolCallApprovalPolicy(GlobalMcpToolCallApprovalPolicy.neverRequireApproval);
      case HostedMcpServerToolRequireSpecificApprovalMode specificMode:
        responsesMcpTool.toolCallApprovalPolicy = mcpToolCallApprovalPolicy(customMcpToolCallApprovalPolicy());
        if (specificMode.alwaysRequireApprovalToolNames is { Count: > 0 } alwaysRequireToolNames) {
          responsesMcpTool.toolCallApprovalPolicy.customPolicy.toolsAlwaysRequiringApproval = new();
          addAllMcpFilters(
            alwaysRequireToolNames,
            responsesMcpTool.toolCallApprovalPolicy.customPolicy.toolsAlwaysRequiringApproval,
          );
      }
        if (specificMode.neverRequireApprovalToolNames is { Count: > 0 } neverRequireToolNames) {
          responsesMcpTool.toolCallApprovalPolicy.customPolicy.toolsNeverRequiringApproval = new();
          addAllMcpFilters(
            neverRequireToolNames,
            responsesMcpTool.toolCallApprovalPolicy.customPolicy.toolsNeverRequiringApproval,
          );
      }
    }
    if ((toolSearchLookup ??= ToolSearchLookup.create(options?.tools)).isDeferred(mcpTool.serverName)) {
      responsesMcpTool.patch.setValue("$.defer_loading"u8, "true"u8);
    }
    return responsesMcpTool;
    default:
    return null;
  }
}
/// Builds a `{"type":"namespace"}` [ResponseTool] from a name and set of
/// tools. The OpenAI .NET SDK doesn't expose a NamespaceTool type, so we
/// construct the JSON manually.
static ResponseTool toNamespaceResponseTool(
  String name,
  String? description,
  Iterable<ResponseTool> namespacedTools,
) {
var stream = System.io.memoryStream();
final writer = utf8JsonWriter(stream);
try {
  writer.writeStartObject();
  writer.writeString("type"u8, "namespace"u8);
  writer.writeString("name"u8, name);
  if (!string.isNullOrEmpty(description)) {
    writer.writeString("description"u8, description);
  }

  writer.writeStartArray("tools"u8);
  for (final namespacedTool in namespacedTools) {
    var toolData = ModelReaderWriter.write(
      namespacedTool,
      ModelReaderWriterOptions.json,
      OpenAIContext.defaultValue,
    );
    var doc = JsonDocument.parse(toolData);
    doc.rootElement.writeTo(writer);
  }

  writer.writeEndArray();
  writer.writeEndObject();
} finally {
  writer.dispose();
}
return ModelReaderWriter.read<ResponseTool>(
  BinaryData.fromBytes(stream.toArray()),
  ModelReaderWriterOptions.json,
  OpenAIContext.defaultValue,
) !;
 }
/// Creates a [ChatRole] from a [MessageRole].
static ChatRole asChatRole(MessageRole? role) {
return role switch
        {
            MessageRole.system => ChatRole.system,
            MessageRole.developer => OpenAIClientExtensions.chatRoleDeveloper,
            MessageRole.user => ChatRole.user,
            (_) => ChatRole.assistant,
        };
 }
/// Creates a [ChatFinishReason] from a [ResponseIncompleteStatusReason].
static ChatFinishReason? asFinishReason(ResponseIncompleteStatusReason? statusReason) {
return statusReason == ResponseIncompleteStatusReason.contentFilter ? ChatFinishReason.contentFilter :
        statusReason == ResponseIncompleteStatusReason.maxOutputTokens ? ChatFinishReason.length :
        null;
 }
/// Converts a [ChatOptions] to a [CreateResponseOptions].
(CreateResponseOptions, String??) asCreateResponseOptions(ChatOptions? options) {
var openAIConversationId = null;
openAIConversationId = null;
if (options == null) {
  return (new()
              {
                  Model = _defaultModelId,
              }, openAIConversationId);
}
var hasRawRco = false;
if (options.rawRepresentationFactory?.invoke(this) is CreateResponseOptions result) {
  hasRawRco = true;
} else {
  result = new();
}
result.backgroundModeEnabled ??= options.allowBackgroundResponses;
result.maxOutputTokenCount ??= options.maxOutputTokens;
result.model ??= options.modelId ?? _defaultModelId;
result.temperature ??= options.temperature;
result.topP ??= options.topP;
result.reasoningOptions ??= toOpenAIResponseReasoningOptions(options.reasoning);
if (result.previousResponseId == null) {
  var chatOptionsHasOpenAIConversationId = OpenAIClientExtensions.isConversationId(options.conversationId);
  if (hasRawRco || chatOptionsHasOpenAIConversationId) {
      openAIConversationId = result.conversationOptions?.conversationId;
      if (openAIConversationId == null && chatOptionsHasOpenAIConversationId) {
            result.conversationOptions = new(options.conversationId);
            openAIConversationId = options.conversationId;
          }
    }
  if (openAIConversationId == null && options.conversationId is { } previousResponseId) {
      result.previousResponseId = previousResponseId;
    }
}
if (options.instructions is { } instructions) {
  result.instructions = string.isNullOrEmpty(result.instructions) ?
                  instructions :
                  '${result.instructions}${Environment.newLine}${instructions}';
}
if (options.tools is { Count: > 0 } tools) {
  var toolSearchLookup = ToolSearchLookup.create(tools);
  var namespaceGroups = null;
  var toolSearchAdded = false;
  for (final tool in tools) {
      if (toResponseTool(tool, options, toolSearchLookup) is { } responseTool) {
            if (tool is HostedToolSearchTool) {
                    if (toolSearchAdded) {
                              continue;
                            }
                    toolSearchAdded = true;
                  }
            var responseToolName = responseTool is FunctionTool ft ? ft.functionName
                                    : responseTool is McpTool mcp ? mcp.serverLabel
                                    : null;
            if (responseToolName != null
                                    && toolSearchLookup.getNamespace(responseToolName) is { } ns) {
                    namespaceGroups ??= new();
                    var group = null;
                    if (!namespaceGroups.tryGetValue(ns, group)) {
                              group = new();
                              namespaceGroups[ns] = group;
                            }
                    group.add(responseTool);
                    continue;
                  }
            result.tools.add(responseTool);
          }
    }
  if (namespaceGroups != null) {
      for (final kvp in namespaceGroups) {
            result.tools.add(toNamespaceResponseTool(kvp.key.name, kvp.key.description, kvp.value));
          }
    }
  if (result.tools.count > 0) {
      result.parallelToolCallsEnabled ??= options.allowMultipleToolCalls;
    }
  if (result.toolChoice == null && result.tools.count > 0) {
      switch (options.toolMode) {
            case NoneChatToolMode:
              result.toolChoice = ResponseToolChoice.createNoneChoice();
            case AutoChatToolMode:
              result.toolChoice = ResponseToolChoice.createAutoChoice();
            case RequiredChatToolMode required:
              result.toolChoice = required.requiredFunctionName != null ?
                                  ResponseToolChoice.createFunctionChoice(required.requiredFunctionName) :
                                  ResponseToolChoice.createRequiredChoice();
          }
    }
}
if (result.textOptions?.textFormat == null &&
            toOpenAIResponseTextFormat(options.responseFormat, options) is { } newFormat) {
  (result.textOptions ??= new()).textFormat = newFormat;
}
return (result, openAIConversationId);
 }
static ResponseTextFormat? toOpenAIResponseTextFormat(
  ChatResponseFormat? format,
  {ChatOptions? options, },
) {
return format switch
        {
            (ChatResponseFormatText) => ResponseTextFormat.createTextFormat(),

            ChatResponseFormatJson jsonFormat when OpenAIClientExtensions.strictSchemaTransformCache.getOrCreateTransformedSchema(jsonFormat) is { } (jsonSchema) =>
                ResponseTextFormat.createJsonSchemaFormat(
                    jsonFormat.schemaName ?? "json_schema",
                    BinaryData.fromBytes(JsonSerializer.serializeToUtf8Bytes(jsonSchema, OpenAIJsonContext.defaultValue.jsonElement)),
                    jsonFormat.schemaDescription,
                    OpenAIClientExtensions.hasStrict(options?.additionalProperties)),

            (ChatResponseFormatJson) => ResponseTextFormat.createJsonObjectFormat(),

            (_) => null,
        };
 }
static ResponseReasoningOptions? toOpenAIResponseReasoningOptions(ReasoningOptions? reasoning) {
if (reasoning == null) {
  return null;
}
var effortLevel = reasoning.effort switch
        {
            ReasoningEffort.none => ResponseReasoningEffortLevel.none,
            ReasoningEffort.low => ResponseReasoningEffortLevel.low,
            ReasoningEffort.medium => ResponseReasoningEffortLevel.medium,
            ReasoningEffort.high => ResponseReasoningEffortLevel.high,
            ReasoningEffort.extraHigh => responseReasoningEffortLevel("xhigh"),
            (_) => (ResponseReasoningEffortLevel?)null,
        };
var summary = reasoning.output switch
        {
            ReasoningOutput.summary => ResponseReasoningSummaryVerbosity.concise,
            ReasoningOutput.full => ResponseReasoningSummaryVerbosity.detailed,
            (_) => (ResponseReasoningSummaryVerbosity?)null, // None or null - let OpenAI use its default
        };
if (effortLevel == null&& summary == null) {
  return null;
}
return responseReasoningOptions();
 }
/// Convert a sequence of [ChatMessage]s to [ResponseItem]s.
static Iterable<ResponseItem> toOpenAIResponseItems(
  Iterable<ChatMessage> inputs,
  ChatOptions? options,
) {
_ = options;
var idToContentMapping = null;
for (final input in inputs) {
  if (input.role == ChatRole.system ||
                input.role == OpenAIClientExtensions.chatRoleDeveloper) {
    var text = input.text;
    if (!string.isNullOrWhiteSpace(text)) {
      yield input.role == ChatRole.system ?
                        ResponseItem.createSystemMessageItem(text) :
                        ResponseItem.createDeveloperMessageItem(text);
    }
    continue;
  }

  if (input.role == ChatRole.user) {
    var parts = null;
    var responseItemYielded = false;
    for (final item in input.contents) {
      var directItem = item switch
                    {
                        { RawRepresentation: ResponseItem rawRep } => rawRep,
                        ToolApprovalResponseContent { ToolCall: McpServerToolCallContent } (toolResp) => ResponseItem.createMcpApprovalResponseItem(toolResp.requestId, toolResp.approved),
                        (_) => null
                    };
      if (directItem != null) {
        if (parts != null) {
          yield ResponseItem.createUserMessageItem(parts);
          parts = null;
        }
        yield directItem;
        responseItemYielded = true;
        continue;
      }
      switch (item) {
        case AIContent:
          (parts ??= []).add(rawRep);
        case TextContent textContent:
          (parts ??= []).add(ResponseContentPart.createInputTextPart(textContent.text));
        case UriContent uriContent:
          (parts ??= []).add(ResponseContentPart.createInputImagePart(uriContent.uri, getImageDetail(item)));
        case UriContent uriContent:
          (parts ??= []).add(ResponseContentPart.createInputFilePart(uriContent.uri));
        case DataContent dataContent:
          (parts ??= []).add(ResponseContentPart.createInputImagePart(BinaryData.fromBytes(dataContent.data, dataContent.mediaType), getImageDetail(item)));
        case DataContent dataContent:
          (parts ??= []).add(ResponseContentPart.createInputFilePart(BinaryData.fromBytes(dataContent.data, dataContent.mediaType), dataContent.mediaType, dataContent.name ?? '${Guid.newGuid():N}.pdf'));
        case HostedFileContent fileContent:
          (parts ??= []).add(ResponseContentPart.createInputImagePart(fileContent.fileId, getImageDetail(item)));
        case HostedFileContent fileContent:
          (parts ??= []).add(ResponseContentPart.createInputFilePart(fileContent.fileId));
        case ErrorContent errorContent:
          (parts ??= []).add(ResponseContentPart.createRefusalPart(errorContent.message));
      }
    }
    if (parts == null && !responseItemYielded) {
      parts = [];
      parts.add(ResponseContentPart.createInputTextPart(string.empty));
      responseItemYielded = true;
    }
    if (parts != null) {
      yield ResponseItem.createUserMessageItem(parts);
      parts = null;
    }
    continue;
  }

  if (input.role == ChatRole.tool) {
    for (final item in input.contents) {
      switch (item) {
        case AIContent:
          yield rawRep;
        case ToolApprovalResponseContent toolResp:
          yield ResponseItem.createMcpApprovalResponseItem(toolResp.requestId, toolResp.approved);
        case FunctionResultContent resultContent:
          /* TODO: unsupported node kind "unknown" */
// static FunctionCallOutputResponseItem SerializeAIContent(string callId, IEnumerable<AIContent> contents)
//                             {
//                                 List<FunctionToolCallOutputElement> elements = [];
//
//                                 foreach (var content in contents)
//                                 {
//                                     switch (content)
//                                     {
//                                         case TextContent tc:
//                                             elements.Add(new()
//                                             {
//                                                 Type = "input_text",
//                                                 Text = tc.Text
//                                             });
//                                             break;
//
//                                         case DataContent dc when dc.HasTopLevelMediaType("image"):
//                                             elements.Add(new()
//                                             {
//                                                 Type = "input_image",
//                                                 ImageUrl = dc.Uri
//                                             });
//                                             break;
//
//                                         case DataContent dc:
//                                             elements.Add(new()
//                                             {
//                                                 Type = "input_file",
//                                                 FileData = dc.Uri, // contrary to the docs, file_data is expected to be a data URI, not just the base64 portion
//                                                 FileName = dc.Name ?? $"file_{Guid.NewGuid():N}", // contrary to the docs, file_name is required
//                                             });
//                                             break;
//
//                                         case UriContent uc when uc.HasTopLevelMediaType("image"):
//                                             elements.Add(new()
//                                             {
//                                                 Type = "input_image",
//                                                 ImageUrl = uc.Uri.AbsoluteUri,
//                                             });
//                                             break;
//
//                                         case UriContent uc:
//                                             elements.Add(new()
//                                             {
//                                                 Type = "input_file",
//                                                 FileUrl = uc.Uri.AbsoluteUri,
//                                             });
//                                             break;
//
//                                         case HostedFileContent fc:
//                                             elements.Add(new()
//                                             {
//                                                 Type = fc.HasTopLevelMediaType("image") ? "input_image" : "input_file",
//                                                 FileId = fc.FileId,
//                                                 FileName = fc.Name,
//                                             });
//                                             break;
//
//                                         default:
//                                             // Fallback to serializing and storing the resulting JSON as text.
//                                             try
//                                             {
//                                                 elements.Add(new()
//                                                 {
//                                                     Type = "input_text",
//                                                     Text = JsonSerializer.Serialize(content, AIJsonUtilities.DefaultOptions.GetTypeInfo(typeof(object))),
//                                                 });
//                                             }
//                                             catch (NotSupportedException)
//                                             {
//                                                 // If the type can't be serialized, skip it.
//                                             }
//                                             break;
//                                     }
//                                 }
//
//                                 FunctionCallOutputResponseItem outputItem = new(callId, string.Empty);
//                                 if (elements.Count > 0)
//                                 {
//                                     outputItem.Patch.Set("$.output"u8, JsonSerializer.SerializeToUtf8Bytes(elements, OpenAIJsonContext.Default.ListFunctionToolCallOutputElement).AsSpan());
//                                 }
//
//                                 return outputItem;
//                             }
          switch (resultContent.result) {
            case AIContent ac:
              yield serializeAIContent(resultContent.callId, [ac]);
            case IEnumerable<AContent> items:
              yield serializeAIContent(resultContent.callId, items);
            default:
              var result = resultContent.result as string;
              if (result == null && resultContent.result is { } resultObj) {
                try {
                  result = JsonSerializer.serialize(
                    resultContent.result,
                    AIJsonUtilities.defaultOptions.getTypeInfo(typeof(object)),
                  );
                } catch (e, s) {
                  if (e is NotSupportedException) {
                    final  = e as NotSupportedException;
                    {}
                  } else {
                    rethrow;
                }
                }
              }
              yield ResponseItem.createFunctionCallOutputItem(
                resultContent.callId,
                result ?? string.empty,
              );
          }
      }
    }
    continue;
  }

  if (input.role == ChatRole.assistant) {
    for (final item in input.contents) {
      switch (item) {
        case AIContent:
          yield rawRep;
        case TextContent textContent:
          yield ResponseItem.createAssistantMessageItem(textContent.text);
        case TextReasoningContent reasoningContent:
          yield reasoningResponseItem(reasoningContent.text);
        case McpServerToolCallContent mstcc:
          (idToContentMapping ??= [])[mstcc.callId] = mstcc;
        case FunctionCallContent callContent:
          yield ResponseItem.createFunctionCallItem(
                                callContent.callId,
                                callContent.name,
                                BinaryData.fromBytes(JsonSerializer.serializeToUtf8Bytes(
                                    callContent.arguments,
                                    AIJsonUtilities.defaultOptions.getTypeInfo(typeof(IDictionary<String, Object?>)))));
        case ToolApprovalRequestContent toolReq:
          yield ResponseItem.createMcpApprovalRequestItem(
                                toolReq.requestId,
                                mcpToolCall.serverName,
                                mcpToolCall.name,
                                BinaryData.fromBytes(JsonSerializer.serializeToUtf8Bytes(
                                    mcpToolCall.arguments!,
                                    AIJsonUtilities.defaultOptions.getTypeInfo(typeof(IDictionary<String, Object?>)))));
        case McpServerToolResultContent mstrc:
          {
            McpServerToolCallContent associatedCall;
            if (idToContentMapping?.tryGetValue(mstrc.callId) is true) {
              _ = idToContentMapping.remove(mstrc.callId);
              var mtci = ResponseItem.createMcpToolCallItem(
                                    associatedCall.serverName,
                                    associatedCall.name,
                                    BinaryData.fromBytes(JsonSerializer.serializeToUtf8Bytes(
                                        associatedCall.arguments!,
                                        AIJsonUtilities.defaultOptions.getTypeInfo(typeof(IDictionary<String, Object?>)))));
              if (mstrc.outputs?.ofType<ErrorContent>().firstOrDefault() is ErrorContent) {
                final errorContent = mstrc.outputs?.ofType<ErrorContent>().firstOrDefault() as ErrorContent;
                mtci.error = BinaryData.fromString(errorContent.message);
              } else {
                mtci.toolOutput = string.concat(mstrc.outputs?.ofType<TextContent>() ?? []);
              }
              yield mtci;
            }
          }
      }
    }
    continue;
  }
}
 }
/// Extract usage details from a [ResponseResult] into a [UsageDetails].
static UsageDetails? toUsageDetails(ResponseResult? responseResult) {
var ud = null;
if (responseResult?.usage is { } usage) {
  ud = new()
            {
                InputTokenCount = usage.inputTokenCount,
                OutputTokenCount = usage.outputTokenCount,
                TotalTokenCount = usage.totalTokenCount,
                CachedInputTokenCount = usage.inputTokenDetails?.cachedTokenCount,
                ReasoningTokenCount = usage.outputTokenDetails?.reasoningTokenCount,
            };
}
return ud;
 }
/// Converts a [UsageDetails] to a [ResponseTokenUsage].
static ResponseTokenUsage? toResponseTokenUsage(UsageDetails? usageDetails) {
var rtu = null;
if (usageDetails != null) {
  rtu = new()
            {
                InputTokenCount = (int?)usageDetails.inputTokenCount ?? 0,
                OutputTokenCount = (int?)usageDetails.outputTokenCount ?? 0,
                TotalTokenCount = (int?)usageDetails.totalTokenCount ?? 0,
                InputTokenDetails = new(),
                OutputTokenDetails = new(),
            };
  if (usageDetails.additionalCounts is { } additionalCounts) {
    int? cachedTokenCount;
    if (additionalCounts.tryGetValue('${nameof(ResponseTokenUsage.inputTokenDetails)}.${nameof(ResponseInputTokenUsageDetails.cachedTokenCount)}')) {
      rtu.inputTokenDetails.cachedTokenCount = cachedTokenCount.getValueOrDefault();
    }
    int? reasoningTokenCount;
    if (additionalCounts.tryGetValue('${nameof(ResponseTokenUsage.outputTokenDetails)}.${nameof(ResponseOutputTokenUsageDetails.reasoningTokenCount)}')) {
      rtu.outputTokenDetails.reasoningTokenCount = reasoningTokenCount.getValueOrDefault();
    }
  }
}
return rtu;
 }
/// Convert a sequence of [ResponseContentPart]s to a list of [AIContent].
static List<AContent> toAIContents(Iterable<ResponseContentPart> contents) {
var results = [];
for (final part in contents) {
  AContent content;
  switch (part.kind) {
    case ResponseContentPartKind.inputText or ResponseContentPartKind.outputText:
      var text = new(part.text);
      populateAnnotations(part, text);
      content = text;
    case ResponseContentPartKind.inputFile or ResponseContentPartKind.inputImage:
      if (!string.isNullOrWhiteSpace(part.inputImageFileId)) {
        content = hostedFileContent(part.inputImageFileId);
      } else if (!string.isNullOrWhiteSpace(part.inputFileId)) {
        content = hostedFileContent(part.inputFileId);
      } else if (part.inputFileBytes != null) {
        content = dataContent(
          part.inputFileBytes,
          part.inputFileBytesMediaType ?? "application/octet-stream",
        );
      } else if (part.inputImageUri is { } inputImageUrl) {
        if (inputImageUrl.startsWith("data:", StringComparison.ordinalIgnoreCase)) {
          content = dataContent(inputImageUrl);
        } else {
          Uri? imageUri;
          if (Uri.tryCreate(inputImageUrl, UriKind.absolute)) {
            content = uriContent(imageUri, OpenAIClientExtensions.imageUriToMediaType(imageUri));
          } else {
            /* TODO: unsupported node kind "unknown" */
// goto default;
          }
        }
      } else {
        /* TODO: unsupported node kind "unknown" */
// goto default;
      }
    case ResponseContentPartKind.refusal:
      content = errorContent(part.refusal);
    default:
      content = new();
  }

  content.rawRepresentation = part;
  results.add(content);
}
return results;
 }
/// Converts any annotations from `source` and stores them in `destination`.
static void populateAnnotations(ResponseContentPart source, AContent destination, ) {
if (source.outputTextAnnotations is { Count: > 0 }) {
  for (final ota in source.outputTextAnnotations) {
    var ca = new()
                {
                    RawRepresentation = ota,
                };
    switch (ota) {
      case ContainerFileCitationMessageAnnotation cfcma:
        ca.annotatedRegions = [textSpanAnnotatedRegion()];
        ca.fileId = cfcma.fileId;
        ca.title = cfcma.filename;
      case FilePathMessageAnnotation fpma:
        ca.fileId = fpma.fileId;
      case FileCitationMessageAnnotation fcma:
        ca.fileId = fcma.fileId;
        ca.title = fcma.filename;
      case UriCitationMessageAnnotation ucma:
        ca.annotatedRegions = [textSpanAnnotatedRegion()];
        ca.url = ucma.uri;
        ca.title = ucma.title;
    }
    (destination.annotations ??= []).add(ca);
  }
}
 }
/// Extracts web search queries from a [WebSearchCallResponseItem].
static List<String>? getWebSearchQueries(WebSearchCallResponseItem wscri) {
if (wscri.action is WebSearchSearchAction) {
    final searchAction = wscri.action as WebSearchSearchAction;
    if (searchAction.queries is { Count: > 0 } queries) {
      return [.. queries];
    }
    if (searchAction.query != null) {
      return [searchAction.query];
    }
  }

return null;
 }
/// Extracts web search sources from a [WebSearchCallResponseItem] when
/// available. Sources are present when the developer opts in via `include:
/// ["web_search_call.action.sources"]`.
static List<AContent>? getWebSearchSources(WebSearchCallResponseItem wscri) {
if (wscri.action is! WebSearchSearchAction { Sources.count: > 0 } searchAction) {
  return null;
}
var results = null;
for (final source in searchAction.sources) {
  if (source is WebSearchActionUriSource { Uri: not null } uriSource) {
    (results ??= []).add(uriContent(uriSource.uri, "text/html"));
  }
}
return results;
 }
/// Adds new [AIContent] for the specified `mtci` into `contents`.
static void addMcpToolCallContent(McpToolCallItem mtci, List<AContent> contents, ) {
contents.add(mcpServerToolCallContent(mtci.id, mtci.toolName, mtci.serverLabel));
contents.add(mcpServerToolResultContent(mtci.id));
 }
/// Adds all of the tool names from `toolNames` to `filter`.
static void addAllMcpFilters(List<String> toolNames, McpToolFilter filter, ) {
for (final toolName in toolNames) {
  filter.toolNames.add(toolName);
}
 }
/// Creates a [CodeInterpreterToolResultContent] for the specified `cicri`.
static CodeInterpreterToolResultContent createCodeInterpreterResultContent(CodeInterpreterCallResponseItem cicri) {
var outputContents = null;
if (cicri.outputs is { Count: > 0 } outputs) {
  outputContents = [];
  for (final o in outputs) {
    switch (o) {
      case CodeInterpreterCallImageOutput cicio:
        outputContents.add(uriContent(cicio.imageUri, OpenAIClientExtensions.imageUriToMediaType(cicio.imageUri)) { RawRepresentation = cicio });
      case CodeInterpreterCallLogsOutput ciclo:
        outputContents.add(textContent(ciclo.logs));
      default:
        // The SDK doesn't publicly expose file output types, so try to extract
                        // file references from the raw JSON via the Patch property.
                        addHostedFileContents(outputContents, o, cicri.containerId);
    }
  }

  if (outputContents.count == 0) {
    outputContents = null;
  }
}
return new(cicri.id)
        {
            Outputs = outputContents,
            RawRepresentation = cicri,
        };
 }
/// Tries to extract file references from an unknown
/// [CodeInterpreterCallOutput] by reading its JSON data via the [Patch]
/// property.
static void addHostedFileContents(
  List<AContent> contents,
  CodeInterpreterCallOutput output,
  String? containerId,
) {
ReadOnlyMemory<byte> filesJson;
if (!output.patch.tryGetJson("$.files"u8)) {
  return;
}
JsonDocument doc;
try {
  doc = JsonDocument.parse(filesJson);
} catch (e, s) {
  if (e is JsonException) {
    final  = e as JsonException;
    {
    return;
  }

  } else {
    rethrow;
}
}
try {
  if (doc.rootElement.valueKind != JsonValueKind.array) {
    return;
  }

  for (final fileElement in doc.rootElement.enumerateArray()) {
    var fileId = (fileElement.tryGetProperty("file_id", out var idProp) ? idProp.getString() : null) ??
                    (fileElement.tryGetProperty("id", out idProp) ? idProp.getString() : null);
    if (fileId == null) {
      continue;
    }
    var mimeType = fileElement.tryGetProperty(
      "mime_type",
      out var mimeProp,
    ) ? mimeProp.getString() : null;
    var hfc = hostedFileContent(fileId);
    if (containerId != null) {
      hfc.scope = containerId;
    }
    contents.add(hfc);
  }

} finally {
  doc.dispose();
}
 }
static void addImageGenerationContents(
  ImageGenerationCallResponseItem outputItem,
  CreateResponseOptions? options,
  List<AContent> contents,
) {
var imageGenTool = options?.tools.ofType<ImageGenerationTool>().firstOrDefault();
var outputFormat = imageGenTool?.outputFileFormat?.toString() ?? "png";
contents.add(imageGenerationToolCallContent(outputItem.id));
contents.add(imageGenerationToolResultContent(outputItem.id)')]
        });
 }
static ImageGenerationToolResultContent getImageGenerationResult(
  StreamingResponseImageGenerationCallPartialImageUpdate update,
  CreateResponseOptions? options,
) {
var imageGenTool = options?.tools.ofType<ImageGenerationTool>().firstOrDefault();
var outputType = imageGenTool?.outputFileFormat?.toString() ?? "png";
return imageGenerationToolResultContent(update.itemId)')
                {
                    AdditionalProperties = new()
                    {
                        [nameof(update.itemId)] = update.itemId,
                        [nameof(update.outputIndex)] = update.outputIndex,
                        [nameof(update.partialImageIndex)] = update.partialImageIndex
                    }
                }
            ]
        };
 }
static ResponsesClientContinuationToken? createContinuationToken({ResponseResult? responseResult, String? responseId, ResponseStatus? responseStatus, bool? isBackgroundModeEnabled, int? updateSequenceNumber, }) {
return createContinuationToken(
            responseId: responseResult.id,
            responseStatus: responseResult.status,
            isBackgroundModeEnabled: responseResult.backgroundModeEnabled);
 }
static ResponsesClientContinuationToken? getContinuationToken(
  Iterable<ChatMessage> messages,
  {ChatOptions? options, },
) {
if (options?.continuationToken is { } token) {
  if (messages.any()) {
    throw invalidOperationException("Messages are not allowed when continuing a background response using a continuation token.");
  }

  return ResponsesClientContinuationToken.fromToken(token);
}
return null;
 }
static ResponseImageDetailLevel? getImageDetail(AContent content) {
Object? value;
if (content.additionalProperties?.tryGetValue("detail") is true) {
  return value switch
            {
                string (detailString) => responseImageDetailLevel(detailString),
                ResponseImageDetailLevel (detail) => detail,
                (_) => null
            };
}
return null;
 }
 }
/// DTO for an array element in OpenAI Responses' "Function tool call output".
class FunctionToolCallOutputElement {
  FunctionToolCallOutputElement();

  String? type;

  String? text;

  String? imageUrl;

  String? fileId;

  String? fileData;

  String? fileUrl;

  String? fileName;

}
/// Provides an [AITool] wrapper for a [ResponseTool].
class ResponseToolATool extends ATool {
  /// Provides an [AITool] wrapper for a [ResponseTool].
  const ResponseToolATool(ResponseTool tool) : tool = tool;

  ResponseTool get tool {
    return tool;
  }

  String get name {
    return tool.getType().name;
  }

  @override
  Object? getService(Type serviceType, {Object? serviceKey, }) {
    _ = Throw.ifNull(serviceType);
    return serviceKey == null && serviceType.isInstanceOfType(tool) ? tool :
                base.getService(serviceType, serviceKey);
  }
}
class ToolSearchLookup {
  const ToolSearchLookup(
    bool deferAll,
    Set<String> deferredToolNames,
    Map<String, Namespace> namespacedToolNames,
  ) :
      _deferAll = deferAll,
      _deferredToolNames = deferredToolNames,
      _namespacedToolNames = namespacedToolNames;

  static final ToolSearchLookup _empty = new(
    deferAll: false,
    deferredToolNames: [],
    namespacedToolNames: [],
  );

  final bool _deferAll;

  final Set<String> _deferredToolNames;

  final Map<String, Namespace> _namespacedToolNames;

  static ToolSearchLookup create(List<ATool>? tools) {
    if (tools is not { Count: > 0 }) {
      return _empty;
    }
    var functionAndMcpToolNames = new(
                tools.select(
                    (tool) => tool switch
                    {
                        AIFunctionDeclaration (aiFunction) => aiFunction.name,
                        HostedMcpServerTool (mcpTool) => mcpTool.serverName,
                        (_) => null,
                    })
                .ofType<String>(),
                StringComparer.ordinal);
    if (functionAndMcpToolNames.count == 0) {
      return _empty;
    }
    var deferAll = false;
    var deferredToolNames = new(StringComparer.ordinal);
    var namespacedToolNames = new(StringComparer.ordinal);
    var namespacesByName = new(StringComparer.ordinal);
    var unclaimedToolNames = new(functionAndMcpToolNames, StringComparer.ordinal);
    for (final tool in tools) {
      if (tool is! HostedToolSearchTool toolSearch) {
        continue;
      }
      if (toolSearch.deferredTools is not { } deferredTools) {
        deferAll = true;
        deferredToolNames.unionWith(functionAndMcpToolNames);
        if (toolSearch.namespace is { } nsName && unclaimedToolNames.count > 0) {
          var ns = getOrCreateNamespace(namespacesByName, nsName, toolSearch.namespaceDescription);
          for (final toolName in unclaimedToolNames) {
            namespacedToolNames[toolName] = ns;
          }
          unclaimedToolNames.clear();
        }
        continue;
      }
      for (final deferredTool in deferredTools) {
        if (!functionAndMcpToolNames.contains(deferredTool)) {
          continue;
        }
        _ = deferredToolNames.add(deferredTool);
        if (toolSearch.namespace is { } nsName && unclaimedToolNames.remove(deferredTool)) {
          namespacedToolNames[deferredTool] = getOrCreateNamespace(
            namespacesByName,
            nsName,
            toolSearch.namespaceDescription,
          );
        }
      }
    }
    return new(deferAll, deferredToolNames, namespacedToolNames);
  }

  bool isDeferred(String toolName) {
    return _deferAll || _deferredToolNames.contains(toolName);
  }

  Namespace? getNamespace(String toolName) {
    return _namespacedToolNames.tryGetValue(toolName, out Namespace? ns) ? ns : null;
  }

  static Namespace getOrCreateNamespace(
    Map<String, Namespace> namespacesByName,
    String name,
    String? description,
  ) {
    Namespace? existing;
    if (!namespacesByName.tryGetValue(name)) {
      existing = namespace(name);
      namespacesByName[name] = existing;
    } else if (string.isNullOrEmpty(existing.description)) {
      existing.description = description;
    }
    return existing;
  }
}
class Namespace {
  const Namespace(String name) : name = name;

  final String name;

  String? description;

}
