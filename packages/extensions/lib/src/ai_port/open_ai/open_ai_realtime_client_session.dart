import '../abstractions/chat_completion/chat_client_metadata.dart';
import '../abstractions/chat_completion/chat_role.dart';
import '../abstractions/chat_completion/chat_tool_mode.dart';
import '../abstractions/chat_completion/none_chat_tool_mode.dart';
import '../abstractions/chat_completion/required_chat_tool_mode.dart';
import '../abstractions/contents/ai_content.dart';
import '../abstractions/contents/data_content.dart';
import '../abstractions/contents/error_content.dart';
import '../abstractions/contents/function_call_content.dart';
import '../abstractions/contents/function_result_content.dart';
import '../abstractions/contents/mcp_server_tool_call_content.dart';
import '../abstractions/contents/mcp_server_tool_result_content.dart';
import '../abstractions/contents/text_content.dart';
import '../abstractions/contents/tool_approval_request_content.dart';
import '../abstractions/functions/ai_function.dart';
import '../abstractions/hosted_mcp_server_tool_always_require_approval_mode.dart';
import '../abstractions/hosted_mcp_server_tool_never_require_approval_mode.dart';
import '../abstractions/hosted_mcp_server_tool_require_specific_approval_mode.dart';
import '../abstractions/realtime/create_conversation_item_realtime_client_message.dart';
import '../abstractions/realtime/create_response_realtime_client_message.dart';
import '../abstractions/realtime/error_realtime_server_message.dart';
import '../abstractions/realtime/input_audio_buffer_append_realtime_client_message.dart';
import '../abstractions/realtime/input_audio_buffer_commit_realtime_client_message.dart';
import '../abstractions/realtime/input_audio_transcription_realtime_server_message.dart';
import '../abstractions/realtime/output_text_audio_realtime_server_message.dart';
import '../abstractions/realtime/realtime_audio_format.dart';
import '../abstractions/realtime/realtime_client_message.dart';
import '../abstractions/realtime/realtime_client_session.dart';
import '../abstractions/realtime/realtime_conversation_item.dart';
import '../abstractions/realtime/realtime_server_message.dart';
import '../abstractions/realtime/realtime_server_message_type.dart';
import '../abstractions/realtime/realtime_session_kind.dart';
import '../abstractions/realtime/realtime_session_options.dart';
import '../abstractions/realtime/response_created_realtime_server_message.dart';
import '../abstractions/realtime/response_output_item_realtime_server_message.dart';
import '../abstractions/realtime/session_update_realtime_client_message.dart';
import '../abstractions/speech_to_text/transcription_options.dart';
import '../abstractions/tools/ai_tool.dart';
import '../abstractions/tools/hosted_mcp_server_tool.dart';
import '../abstractions/usage_details.dart';
import 'open_ai_json_context.dart';
import 'open_ai_realtime_conversation_client.dart';

/// Represents an [RealtimeClientSession] for the OpenAI Realtime API over
/// WebSocket.
class OpenARealtimeClientSession implements RealtimeClientSession {
  /// Initializes a new instance of the [OpenAIRealtimeClientSession] class.
  ///
  /// [apiKey] The API key used for authentication.
  ///
  /// [model] The model to use for the session.
  OpenARealtimeClientSession(
    String model,
    {String? apiKey = null, RealtimeSessionClient? sessionClient = null, },
  ) :
      _ownedRealtimeClient = Sdk.realtimeClient(Throw.ifNull(apiKey)),
      _model = Throw.ifNull(model),
      _metadata = new("openai", defaultModelId: _model);

  /// The model to use for the session.
  final String _model;

  /// Metadata about this session's provider and model, used for OpenTelemetry.
  final ChatClientMetadata _metadata;

  /// Owned [RealtimeClient] created from the (apiKey, model) constructor path.
  RealtimeClient? _ownedRealtimeClient;

  /// The SDK session client for communication with the Realtime API.
  RealtimeSessionClient? _sessionClient;

  /// Whether the session has been disposed (0 = false, 1 = true).
  int _disposed;

  RealtimeSessionOptions? options;

  /// Connects the WebSocket to the OpenAI Realtime API.
  ///
  /// Returns: A task representing the asynchronous connect operation.
  ///
  /// [cancellationToken] The [CancellationToken] to monitor for cancellation
  /// requests.
  Future connect({CancellationToken? cancellationToken}) async  {
    if (_ownedRealtimeClient == null) {
      Throw.invalidOperationException("Cannot connect a session that was not created with an owned realtime client.");
    }
    _sessionClient = await _ownedRealtimeClient.startConversationSessionAsync(
            _model, cancellationToken: cancellationToken).configureAwait(false);
  }

  Future updateSession(
    RealtimeSessionOptions options,
    CancellationToken cancellationToken,
  ) async  {
    if (_sessionClient != null) {
      var rawOptions = options.rawRepresentationFactory?.invoke();
      if (rawOptions is RealtimeTranscriptionSessionOptions) {
        final rawTransOptions = rawOptions as RealtimeTranscriptionSessionOptions;
        await _sessionClient.configureTranscriptionSessionAsync(
          rawTransOptions,
          cancellationToken,
        ) .configureAwait(false);
      } else if (options.sessionKind == RealtimeSessionKind.transcription) {
        var transOpts = buildTranscriptionSessionOptions(options);
        await _sessionClient.configureTranscriptionSessionAsync(
          transOpts,
          cancellationToken,
        ) .configureAwait(false);
      } else {
        var convOpts = buildConversationSessionOptions(
          options,
          rawOptions as Sdk.realtimeConversationSessionOptions,
        );
        await _sessionClient.configureConversationSessionAsync(
          convOpts,
          cancellationToken,
        ) .configureAwait(false);
      }
    }
    options = options;
  }

  @override
  Future send(RealtimeClientMessage message, {CancellationToken? cancellationToken, }) async  {
    _ = Throw.ifNull(message);
    cancellationToken.throwIfCancellationRequested();
    if (_sessionClient == null) {
      Throw.invalidOperationException("The session is! connected.");
    }
    switch (message) {
      case SessionUpdateRealtimeClientMessage sessionUpdate:
      await updateSessionAsync(sessionUpdate.options, cancellationToken).configureAwait(false);
      case CreateResponseRealtimeClientMessage responseCreate:
      await sendResponseCreateAsync(responseCreate, cancellationToken).configureAwait(false);
      case CreateConversationItemRealtimeClientMessage itemCreate:
      await sendConversationItemCreateAsync(itemCreate, cancellationToken).configureAwait(false);
      case InputAudioBufferAppendRealtimeClientMessage audioAppend:
      await sendInputAudioAppendAsync(audioAppend, cancellationToken).configureAwait(false);
      case InputAudioBufferCommitRealtimeClientMessage:
      if (message.messageId != null) {
        var cmd = Sdk.realtimeClientCommandInputAudioBufferCommit();
        await _sessionClient.sendCommandAsync(cmd, cancellationToken).configureAwait(false);
      } else {
        await _sessionClient.commitPendingAudioAsync(cancellationToken).configureAwait(false);
      }
      default:
      await sendRawCommandAsync(message, cancellationToken).configureAwait(false);
    }
  }

  @override
  Stream<RealtimeServerMessage> getStreamingResponse({CancellationToken? cancellationToken}) async  {
    if (_sessionClient == null) {
      return;
    }
    for (final update in _sessionClient.receiveUpdatesAsync(cancellationToken).configureAwait(false)) {
      var serverMessage = mapServerUpdate(update);
      if (serverMessage != null) {
        yield serverMessage;
      }
    }
  }

  Object? getService(Type serviceType, Object? serviceKey, ) {
    _ = Throw.ifNull(serviceType);
    return serviceKey != null ? null :
            serviceType == typeof(ChatClientMetadata) ? _metadata :
            serviceType.isInstanceOfType(this) ? this :
            _sessionClient != null && serviceType.isInstanceOfType(_sessionClient) ? _sessionClient :
            null;
  }

  @override
  Future dispose() {
    if (Interlocked.exchange(ref _disposed, 1) != 0) {
      return Future.value();
    }
    _sessionClient?.dispose();
    return Future.value();
  }

  Future sendResponseCreate(
    CreateResponseRealtimeClientMessage responseCreate,
    CancellationToken cancellationToken,
  ) async  {
    var responseOptions = Sdk.realtimeResponseOptions();
    if (responseCreate.outputAudioOptions != null || !string.isNullOrEmpty(responseCreate.outputVoice)) {
      responseOptions.audioOptions = Sdk.realtimeResponseAudioOptions();
      if (responseCreate.outputAudioOptions != null) {
        responseOptions.audioOptions.outputAudioOptions.audioFormat = toSdkAudioFormat(responseCreate.outputAudioOptions);
      }
      if (!string.isNullOrEmpty(responseCreate.outputVoice)) {
        responseOptions.audioOptions.outputAudioOptions.voice = Sdk.realtimeVoice(responseCreate.outputVoice);
      }
    }
    if (responseCreate.excludeFromConversation is bool) {
      final excludeFromConversation = responseCreate.excludeFromConversation as bool;
      responseOptions.defaultConversationConfiguration = excludeFromConversation
                ? Sdk.realtimeResponseDefaultConversationConfiguration.none
                : Sdk.realtimeResponseDefaultConversationConfiguration.auto;
    }
    if (responseCreate.items is { } items) {
      for (final item in items) {
        if (toRealtimeItem(item) is RealtimeItem) {
          final sdkItem = toRealtimeItem(item) as RealtimeItem;
          responseOptions.inputItems.add(sdkItem);
        }
      }
    }
    if (!string.isNullOrEmpty(responseCreate.instructions)) {
      responseOptions.instructions = responseCreate.instructions;
    }
    if (responseCreate.maxOutputTokens.hasValue) {
      responseOptions.maxOutputTokenCount = responseCreate.maxOutputTokens.value;
    }
    if (responseCreate.additionalProperties is { Count: > 0 }) {
      var metadata = new Dictionary<String, BinaryData>();
      for (final kvp in responseCreate.additionalProperties) {
        metadata[kvp.key] = BinaryData.fromString(kvp.value?.toString() ?? string.empty);
      }
      responseOptions.metadata = metadata;
    }
    if (responseCreate.outputModalities != null) {
      for (final modality in responseCreate.outputModalities) {
        responseOptions.outputModalities.add(Sdk.realtimeOutputModality(modality));
      }
    }
    if (responseCreate.toolMode is { } toolMode) {
      responseOptions.toolChoice = toSdkToolChoice(toolMode);
    }
    if (responseCreate.tools != null) {
      for (final tool in responseCreate.tools) {
        if (toRealtimeTool(tool) is RealtimeTool) {
          final sdkTool = toRealtimeTool(tool) as RealtimeTool;
          responseOptions.tools.add(sdkTool);
        }
      }
    }
    if (responseCreate.messageId != null) {
      var cmd = Sdk.realtimeClientCommandResponseCreate();
      await _sessionClient!.sendCommandAsync(cmd, cancellationToken).configureAwait(false);
    } else {
      await _sessionClient!.startResponseAsync(
        responseOptions,
        cancellationToken,
      ) .configureAwait(false);
    }
  }

  Future sendConversationItemCreate(
    CreateConversationItemRealtimeClientMessage itemCreate,
    CancellationToken cancellationToken,
  ) async  {
    if (itemCreate.item == null) {
      return;
    }
    var sdkItem = toRealtimeItem(itemCreate.item);
    if (sdkItem == null) {
      return;
    }
    var previousId = null;
    if (itemCreate.rawRepresentation is RealtimeClientCommandConversationItemCreate) {
      final rawCmd = itemCreate.rawRepresentation as RealtimeClientCommandConversationItemCreate;
      previousId = rawCmd.previousItemId;
    }
    if (itemCreate.messageId != null|| previousId != null) {
      var cmd = Sdk.realtimeClientCommandConversationItemCreate(sdkItem);
      await _sessionClient!.sendCommandAsync(cmd, cancellationToken).configureAwait(false);
    } else {
      await _sessionClient!.addItemAsync(sdkItem, cancellationToken).configureAwait(false);
    }
  }

  Future sendInputAudioAppend(
    InputAudioBufferAppendRealtimeClientMessage audioAppend,
    CancellationToken cancellationToken,
  ) async  {
    if (audioAppend.content == null || !audioAppend.content.hasTopLevelMediaType("audio")) {
      return;
    }
    var audioData = extractAudioBinaryData(audioAppend.content);
    if (audioAppend.messageId != null) {
      var cmd = Sdk.realtimeClientCommandInputAudioBufferAppend(audioData);
      await _sessionClient!.sendCommandAsync(cmd, cancellationToken).configureAwait(false);
    } else {
      await _sessionClient!.sendInputAudioAsync(audioData, cancellationToken).configureAwait(false);
    }
  }

  Future sendRawCommand(
    RealtimeClientMessage message,
    CancellationToken cancellationToken,
  ) async  {
    if (message.rawRepresentation is RealtimeClientCommand) {
      final sdkCmd = message.rawRepresentation as RealtimeClientCommand;
      await _sessionClient!.sendCommandAsync(sdkCmd, cancellationToken).configureAwait(false);
      return;
    }
    var jsonString = message.rawRepresentation switch
        {
            string (s) => s,
            JsonObject (obj) => obj.toJsonString(),
            (_) => null,
        };
    if (jsonString != null) {
      if (message.messageId != null && !jsonString.contains("\"event_id\"", StringComparison.ordinal)) {
        jsonString = jsonString.insert(
          1,
          '\"event_id\":${JsonSerializer.serialize(message.messageId, OpenAIJsonContext.defaultValue.string)},
          ',
        );
      }
      await _sessionClient!.sendCommandAsync(
        BinaryData.fromString(jsonString),
        null,
      ) .configureAwait(false);
    }
  }

  static RealtimeConversationSessionOptions buildConversationSessionOptions(
    RealtimeSessionOptions options,
    {RealtimeConversationSessionOptions? seedOptions, },
  ) {
    var convOptions = seedOptions ?? Sdk.realtimeConversationSessionOptions();
    var audioOptions = convOptions.audioOptions ?? Sdk.realtimeConversationSessionAudioOptions();
    var inputAudioOptions = audioOptions.inputAudioOptions ?? Sdk.realtimeConversationSessionInputAudioOptions();
    var outputAudioOptions = audioOptions.outputAudioOptions ?? Sdk.realtimeConversationSessionOutputAudioOptions();
    if (options.inputAudioFormat != null) {
      inputAudioOptions.audioFormat = toSdkAudioFormat(options.inputAudioFormat);
    }
    if (options.transcriptionOptions != null) {
      inputAudioOptions.audioTranscriptionOptions = Sdk.realtimeAudioTranscriptionOptions();
    }
    if (options.outputAudioFormat != null) {
      outputAudioOptions.audioFormat = toSdkAudioFormat(options.outputAudioFormat);
    }
    if (options.voice != null) {
      outputAudioOptions.voice = Sdk.realtimeVoice(options.voice);
    }
    if (options.voiceActivityDetection is { } vad) {
      if (!vad.enabled) {
        inputAudioOptions.disableTurnDetection();
      } else if (inputAudioOptions.turnDetection is RealtimeServerVadTurnDetection) {
        final existingVad = inputAudioOptions.turnDetection as RealtimeServerVadTurnDetection;
        existingVad.interruptResponseEnabled = vad.allowInterruption;
      } else {
        inputAudioOptions.turnDetection = Sdk.realtimeServerVadTurnDetection();
      }
    }
    audioOptions.inputAudioOptions = inputAudioOptions;
    audioOptions.outputAudioOptions = outputAudioOptions;
    convOptions.audioOptions = audioOptions;
    if (options.instructions != null) {
      convOptions.instructions = options.instructions;
    }
    if (options.maxOutputTokens.hasValue) {
      convOptions.maxOutputTokenCount = options.maxOutputTokens.value;
    }
    if (options.model != null) {
      convOptions.model = options.model;
    }
    if (options.outputModalities != null) {
      for (final modality in options.outputModalities) {
        convOptions.outputModalities.add(Sdk.realtimeOutputModality(modality));
      }
    }
    if (options.toolMode is { } toolMode) {
      convOptions.toolChoice = toSdkToolChoice(toolMode);
    }
    if (options.tools != null) {
      for (final tool in options.tools) {
        if (toRealtimeTool(tool) is RealtimeTool) {
          final sdkTool = toRealtimeTool(tool) as RealtimeTool;
          convOptions.tools.add(sdkTool);
        }
      }
    }
    return convOptions;
  }

  static RealtimeTranscriptionSessionOptions buildTranscriptionSessionOptions(RealtimeSessionOptions options) {
    var transOptions = Sdk.realtimeTranscriptionSessionOptions();
    if (options.inputAudioFormat != null|| options.transcriptionOptions != null|| options.voiceActivityDetection != null) {
      var inputAudioOptions = Sdk.realtimeTranscriptionSessionInputAudioOptions();
      if (options.inputAudioFormat != null) {
        inputAudioOptions.audioFormat = toSdkAudioFormat(options.inputAudioFormat);
      }
      if (options.transcriptionOptions != null) {
        inputAudioOptions.audioTranscriptionOptions = Sdk.realtimeAudioTranscriptionOptions();
      }
      if (options.voiceActivityDetection is { } vad) {
        if (!vad.enabled) {
          inputAudioOptions.disableTurnDetection();
        } else if (inputAudioOptions.turnDetection is RealtimeServerVadTurnDetection) {
          final existingVad = inputAudioOptions.turnDetection as RealtimeServerVadTurnDetection;
          existingVad.interruptResponseEnabled = vad.allowInterruption;
        } else {
          inputAudioOptions.turnDetection = Sdk.realtimeServerVadTurnDetection();
        }
      }
      transOptions.audioOptions = Sdk.realtimeTranscriptionSessionAudioOptions();
    }
    return transOptions;
  }

  static RealtimeTool? toRealtimeTool(ATool tool) {
    if (tool is AIFunction aiFunction && !string.isNullOrEmpty(aiFunction.name)) {
      return OpenAIRealtimeConversationClient.toOpenAIRealtimeFunctionTool(aiFunction);
    }
    if (tool is HostedMcpServerTool) {
      final mcpTool = tool as HostedMcpServerTool;
      return toRealtimeMcpTool(mcpTool);
    }
    return null;
  }

  static RealtimeMcpTool toRealtimeMcpTool(HostedMcpServerTool mcpTool) {
    Sdk.RealtimeMcpTool sdkTool;
    var uri;
    if (Uri.tryCreate(mcpTool.serverAddress, UriKind.absolute)) {
      sdkTool = Sdk.realtimeMcpTool(mcpTool.serverName, uri);
      if (mcpTool.headers is { } headers) {
        var sdkHeaders = new Dictionary<String, String>(StringComparer.ordinalIgnoreCase);
        for (final kvp in headers) {
          sdkHeaders[kvp.key] = kvp.value;
        }
        sdkTool.headers = sdkHeaders;
      }
    } else {
      sdkTool = Sdk.realtimeMcpTool(
        mcpTool.serverName,
        Sdk.realtimeMcpToolConnectorId(mcpTool.serverAddress),
      );
    }
    if (mcpTool.serverDescription != null) {
      sdkTool.serverDescription = mcpTool.serverDescription;
    }
    if (mcpTool.allowedTools is { Count: > 0 }) {
      sdkTool.allowedTools = Sdk.realtimeMcpToolFilter();
      for (final toolName in mcpTool.allowedTools) {
        sdkTool.allowedTools.toolNames.add(toolName);
      }
    }
    if (mcpTool.approvalMode != null) {
      sdkTool.toolCallApprovalPolicy = mcpTool.approvalMode switch
            {
                (HostedMcpServerToolAlwaysRequireApprovalMode) => Sdk.realtimeDefaultMcpToolCallApprovalPolicy.alwaysRequireApproval,
                (HostedMcpServerToolNeverRequireApprovalMode) => Sdk.realtimeDefaultMcpToolCallApprovalPolicy.neverRequireApproval,
                HostedMcpServerToolRequireSpecificApprovalMode (specific) => toSdkCustomApprovalPolicy(specific),
                (_) => Sdk.realtimeDefaultMcpToolCallApprovalPolicy.alwaysRequireApproval,
            };
    }
    return sdkTool;
  }

  static RealtimeMcpToolCallApprovalPolicy toSdkCustomApprovalPolicy(HostedMcpServerToolRequireSpecificApprovalMode mode) {
    var custom = Sdk.realtimeCustomMcpToolCallApprovalPolicy();
    if (mode.alwaysRequireApprovalToolNames is { Count: > 0 }) {
      custom.toolsAlwaysRequiringApproval = Sdk.realtimeMcpToolFilter();
      for (final name in mode.alwaysRequireApprovalToolNames) {
        custom.toolsAlwaysRequiringApproval.toolNames.add(name);
      }
    }
    if (mode.neverRequireApprovalToolNames is { Count: > 0 }) {
      custom.toolsNeverRequiringApproval = Sdk.realtimeMcpToolFilter();
      for (final name in mode.neverRequireApprovalToolNames) {
        custom.toolsNeverRequiringApproval.toolNames.add(name);
      }
    }
    return custom;
  }

  static RealtimeItem? toRealtimeItem(RealtimeConversationItem? contentItem) {
    if (contentItem?.contents == null or { Count: 0 }) {
      return null;
    }
    var firstContent = contentItem.contents[0];
    if (firstContent is FunctionResultContent) {
      final functionResult = firstContent as FunctionResultContent;
      var resultJson = functionResult.result != null
                ? JsonSerializer.serialize(
                  functionResult.result,
                  AIJsonUtilities.defaultOptions.getTypeInfo(typeof(object)),
                )
                : string.empty;
      return Sdk.realtimeItem.createFunctionCallOutputItem(
                functionResult.callId ?? string.empty,
                resultJson);
    }
    if (firstContent is FunctionCallContent) {
      final functionCall = firstContent as FunctionCallContent;
      var arguments = functionCall.arguments != null
                ? BinaryData.fromString(JsonSerializer.serialize(functionCall.arguments, OpenAIJsonContext.defaultValue.iDictionaryStringObject))
                : BinaryData.fromString("{}");
      return Sdk.realtimeItem.createFunctionCallItem(
                functionCall.callId ?? string.empty,
                functionCall.name,
                arguments);
    }
    if (firstContent is ToolApprovalResponseContent) {
      final approvalResponse = firstContent as ToolApprovalResponseContent;
      return Sdk.realtimeItem.createMcpApprovalResponseItem(
                approvalResponse.requestId ?? string.empty,
                approvalResponse.approved);
    }
    var contentParts = List<Sdk.realtimeMessageContentPart>();
    for (final content in contentItem.contents) {
      if (content is TextContent) {
        final textContent = content as TextContent;
        contentParts.add(Sdk.realtimeInputTextMessageContentPart(textContent.text ?? string.empty));
      } else if (content is DataContent) {
        final dataContent = content as DataContent;
        if (dataContent.mediaType?.startsWith("audio/", StringComparison.ordinal) == true) {
          contentParts.add(Sdk.realtimeInputAudioMessageContentPart(
                        BinaryData.fromBytes(dataContent.data.toArray())));
        } else if (dataContent.mediaType?.startsWith("image/", StringComparison.ordinal) == true && dataContent.uri != null) {
          contentParts.add(Sdk.realtimeInputImageMessageContentPart(uri(dataContent.uri)));
        }
      }
    }
    if (contentParts.count == 0) {
      return null;
    }
    var role = contentItem.role?.value switch
        {
            "assistant" => Sdk.realtimeMessageRole.assistant,
            "system" => Sdk.realtimeMessageRole.system,
            (_) => Sdk.realtimeMessageRole.user,
        };
    var messageItem = Sdk.realtimeMessageItem(role, contentParts);
    if (contentItem.id != null) {
      messageItem.id = contentItem.id;
    }
    return messageItem;
  }

  static RealtimeToolChoice toSdkToolChoice(ChatToolMode toolMode) {
    return toolMode switch
    {
        RequiredChatToolMode r when r.requiredFunctionName != (null) =>
            Sdk.realtimeToolChoice(Sdk.realtimeCustomFunctionToolChoice(r.requiredFunctionName)),
        (RequiredChatToolMode) => Sdk.realtimeDefaultToolChoice.required,
        (NoneChatToolMode) => Sdk.realtimeDefaultToolChoice.none,
        (_) => Sdk.realtimeDefaultToolChoice.auto,
    };
  }

  static RealtimeAudioFormat? toSdkAudioFormat(RealtimeAudioFormat? format) {
    if (format == null) {
      return null;
    }
    return format.mediaType switch
        {
            "audio/pcm" => Sdk.realtimePcmAudioFormat(),
            "audio/pcmu" => Sdk.realtimePcmuAudioFormat(),
            "audio/pcma" => Sdk.realtimePcmaAudioFormat(),
            (_) => null,
        };
  }

  static BinaryData extractAudioBinaryData(DataContent content) {
    var dataUri = content.uri?.toString() ?? string.empty;
    var commaIndex = dataUri.lastIndexOf(',');
    if (commaIndex >= 0 && commaIndex < dataUri.length - 1) {
      var base64 = dataUri.substring(commaIndex + 1);
      return BinaryData.fromBytes(Convert.fromBase64String(base64));
    }
    return BinaryData.fromBytes(content.data.toArray());
  }

  RealtimeServerMessage? mapServerUpdate(RealtimeServerUpdate update) {
    return update switch
    {
        Sdk.realtimeServerUpdateError (e) => mapError(e),
        Sdk.realtimeServerUpdateSessionCreated (e) => handleSessionEvent(e.session, e),
        Sdk.realtimeServerUpdateSessionUpdated (e) => handleSessionEvent(e.session, e),
        Sdk.realtimeServerUpdateResponseCreated (e) => mapResponseCreatedOrDone(e.eventId, e.response, RealtimeServerMessageType.responseCreated, e),
        Sdk.realtimeServerUpdateResponseDone (e) => mapResponseCreatedOrDone(e.eventId, e.response, RealtimeServerMessageType.responseDone, e),
        Sdk.realtimeServerUpdateResponseOutputItemAdded (e) => mapResponseOutputItem(e.eventId, e.responseId, e.outputIndex, e.item, RealtimeServerMessageType.responseOutputItemAdded, e),
        Sdk.realtimeServerUpdateResponseOutputItemDone (e) => mapResponseOutputItem(e.eventId, e.responseId, e.outputIndex, e.item, RealtimeServerMessageType.responseOutputItemDone, e),
        Sdk.realtimeServerUpdateResponseOutputAudioDelta (e) => outputTextAudioRealtimeServerMessage(RealtimeServerMessageType.outputAudioDelta),
        Sdk.realtimeServerUpdateResponseOutputAudioDone (e) => outputTextAudioRealtimeServerMessage(RealtimeServerMessageType.outputAudioDone),
        Sdk.realtimeServerUpdateResponseOutputAudioTranscriptDelta (e) => outputTextAudioRealtimeServerMessage(RealtimeServerMessageType.outputAudioTranscriptionDelta),
        Sdk.realtimeServerUpdateResponseOutputAudioTranscriptDone (e) => outputTextAudioRealtimeServerMessage(RealtimeServerMessageType.outputAudioTranscriptionDone),
        Sdk.realtimeServerUpdateConversationItemInputAudioTranscriptionDelta (e) => mapInputTranscriptionDelta(e),
        Sdk.realtimeServerUpdateConversationItemInputAudioTranscriptionCompleted (e) => mapInputTranscriptionCompleted(e),
        Sdk.realtimeServerUpdateConversationItemInputAudioTranscriptionFailed (e) => mapInputTranscriptionFailed(e),
        Sdk.realtimeServerUpdateConversationItemAdded (e) => mapConversationItem(e.eventId, e.item, RealtimeServerMessageType.conversationItemAdded, e),
        Sdk.realtimeServerUpdateConversationItemDone (e) => mapConversationItem(e.eventId, e.item, RealtimeServerMessageType.conversationItemDone, e),
        Sdk.realtimeServerUpdateResponseMcpCallInProgress (e) => mapMcpCallEvent(e.eventId, e.itemId, e.outputIndex, realtimeServerMessageType("McpCallInProgress"), e),
        Sdk.realtimeServerUpdateResponseMcpCallCompleted (e) => mapMcpCallEvent(e.eventId, e.itemId, e.outputIndex, realtimeServerMessageType("McpCallCompleted"), e),
        Sdk.realtimeServerUpdateResponseMcpCallFailed (e) => mapMcpCallEvent(e.eventId, e.itemId, e.outputIndex, realtimeServerMessageType("McpCallFailed"), e),
        Sdk.realtimeServerUpdateMcpListToolsInProgress (e) => mapMcpListToolsEvent(e.eventId, e.itemId, realtimeServerMessageType("McpListToolsInProgress"), e),
        Sdk.realtimeServerUpdateMcpListToolsCompleted (e) => mapMcpListToolsEvent(e.eventId, e.itemId, realtimeServerMessageType("McpListToolsCompleted"), e),
        Sdk.realtimeServerUpdateMcpListToolsFailed (e) => mapMcpListToolsEvent(e.eventId, e.itemId, realtimeServerMessageType("McpListToolsFailed"), e),
        (_) => realtimeServerMessage(),
    };
  }

  static ErrorRealtimeServerMessage mapError(RealtimeServerUpdateError e) {
    var msg = errorRealtimeServerMessage();
    if (e.error?.code != null) {
      msg.error.errorCode = e.error.code;
    }
    if (e.error?.parameterName != null) {
      msg.error.details = e.error.parameterName;
    }
    return msg;
  }

  RealtimeServerMessage handleSessionEvent(
    RealtimeSession? session,
    RealtimeServerUpdate update,
  ) {
    if (session is RealtimeConversationSession) {
      final convSession = session as RealtimeConversationSession;
      options = mapConversationSessionToOptions(convSession);
    }
    return realtimeServerMessage();
  }

  RealtimeSessionOptions mapConversationSessionToOptions(RealtimeConversationSession session) {
    var inputAudioFormat = null;
    var transcription = null;
    var outputAudioFormat = null;
    var voice = null;
    if (session.audioOptions is { } audioOptions) {
      if (audioOptions.inputAudioOptions is { } inputOpts) {
        inputAudioFormat = mapSdkAudioFormat(inputOpts.audioFormat);
        if (inputOpts.audioTranscriptionOptions is { } transcriptionOpts) {
          transcription = transcriptionOptions();
        }
      }
      if (audioOptions.outputAudioOptions is { } outputOpts) {
        outputAudioFormat = mapSdkAudioFormat(outputOpts.audioFormat);
        if (outputOpts.voice.hasValue) {
          voice = outputOpts.voice.value.toString();
        }
      }
    }
    var maxOutputTokens = null;
    if (session.maxOutputTokenCount is { } maxTokens) {
      maxOutputTokens = maxTokens.customMaxOutputTokenCount ?? int.maxValue;
    }
    var outputModalities = null;
    if (session.outputModalities is { Count: > 0 } modalities) {
      outputModalities = modalities.select((m) => m.toString()).toList();
    }
    return realtimeSessionOptions();
  }

  static ResponseCreatedRealtimeServerMessage mapResponseCreatedOrDone(
    String? eventId,
    RealtimeResponse? response,
    RealtimeServerMessageType type,
    RealtimeServerUpdate update,
  ) {
    var msg = responseCreatedRealtimeServerMessage(type);
    if (response == null) {
      return msg;
    }
    msg.responseId = response.id;
    msg.status = response.status?.toString();
    if (response.audioOptions?.outputAudioOptions is { } audioOut) {
      msg.outputAudioOptions = mapSdkAudioFormat(audioOut.audioFormat);
      if (audioOut.voice.hasValue) {
        msg.outputVoice = audioOut.voice.value.toString();
      }
    }
    if (response.maxOutputTokenCount is { } maxTokens) {
      msg.maxOutputTokens = maxTokens.customMaxOutputTokenCount ?? int.maxValue;
    }
    if (response.metadata is { Count: > 0 } metadata) {
      var dict = additionalPropertiesDictionary();
      for (final kvp in metadata) {
        dict[kvp.key] = kvp.value;
      }
      msg.additionalProperties = dict;
    }
    if (response.outputModalities is { Count: > 0 } modalities) {
      msg.outputModalities = modalities.select((m) => m.toString()).toList();
    }
    if (response.statusDetails?.error is { } error) {
      msg.error = errorContent(error.kind);
    }
    if (response.usage is { } usage) {
      msg.usage = mapUsageDetails(usage);
    }
    if (response.outputItems is { Count: > 0 } outputItems) {
      var items = List<RealtimeConversationItem>();
      for (final item in outputItems) {
        if (mapRealtimeItem(item) is RealtimeConversationItem) {
          final contentItem = mapRealtimeItem(item) as RealtimeConversationItem;
          items.add(contentItem);
        }
      }
      msg.items = items;
    }
    return msg;
  }

  static ResponseOutputItemRealtimeServerMessage mapResponseOutputItem(
    String? eventId,
    String? responseId,
    int outputIndex,
    RealtimeItem? item,
    RealtimeServerMessageType type,
    RealtimeServerUpdate update,
  ) {
    return responseOutputItemRealtimeServerMessage(type);
  }

  static ResponseOutputItemRealtimeServerMessage mapConversationItem(
    String? eventId,
    RealtimeItem? item,
    RealtimeServerMessageType type,
    RealtimeServerUpdate update,
  ) {
    var mapped = item != null ? mapRealtimeItem(item) : null;
    if (mapped == null) {
      return responseOutputItemRealtimeServerMessage(RealtimeServerMessageType.rawContentOnly);
    }
    return responseOutputItemRealtimeServerMessage(type);
  }

  static InputAudioTranscriptionRealtimeServerMessage mapInputTranscriptionDelta(RealtimeServerUpdateConversationItemInputAudioTranscriptionDelta e) {
    return inputAudioTranscriptionRealtimeServerMessage(RealtimeServerMessageType.inputAudioTranscriptionDelta);
  }

  static InputAudioTranscriptionRealtimeServerMessage mapInputTranscriptionCompleted(RealtimeServerUpdateConversationItemInputAudioTranscriptionCompleted e) {
    return inputAudioTranscriptionRealtimeServerMessage(RealtimeServerMessageType.inputAudioTranscriptionCompleted);
  }

  static InputAudioTranscriptionRealtimeServerMessage mapInputTranscriptionFailed(RealtimeServerUpdateConversationItemInputAudioTranscriptionFailed e) {
    var msg = inputAudioTranscriptionRealtimeServerMessage(RealtimeServerMessageType.inputAudioTranscriptionFailed);
    if (e.error != null) {
      msg.error = errorContent(e.error.message);
    }
    return msg;
  }

  static ResponseOutputItemRealtimeServerMessage mapMcpCallEvent(
    String? eventId,
    String? itemId,
    int outputIndex,
    RealtimeServerMessageType type,
    RealtimeServerUpdate update,
  ) {
    return responseOutputItemRealtimeServerMessage(type);
  }

  static ResponseOutputItemRealtimeServerMessage mapMcpListToolsEvent(
    String? eventId,
    String? itemId,
    RealtimeServerMessageType type,
    RealtimeServerUpdate update,
  ) {
    return responseOutputItemRealtimeServerMessage(type);
  }

  static RealtimeConversationItem? mapRealtimeItem(RealtimeItem item) {
    return item switch
    {
        Sdk.realtimeMessageItem (messageItem) => mapMessageItem(messageItem),
        Sdk.realtimeFunctionCallItem (funcCallItem) => mapFunctionCallItem(funcCallItem),
        Sdk.realtimeFunctionCallOutputItem (funcOutputItem) => realtimeConversationItem(
            [functionResultContent(
              funcOutputItem.callId ?? string.empty,
              funcOutputItem.functionOutput,
            ) ],
            funcOutputItem.id),
        Sdk.realtimeMcpToolCallItem (mcpItem) => mapMcpToolCallItem(mcpItem),
        Sdk.realtimeMcpToolCallApprovalRequestItem (approvalItem) => mapMcpApprovalRequestItem(approvalItem),
        Sdk.realtimeMcpToolDefinitionListItem (toolListItem) => mapMcpToolDefinitionListItem(toolListItem),
        (_) => null,
    };
  }

  static RealtimeConversationItem mapFunctionCallItem(RealtimeFunctionCallItem funcCallItem) {
    var arguments = funcCallItem.functionArguments != null && !funcCallItem.functionArguments.isEmpty
            ? JsonSerializer.deserialize(
              funcCallItem.functionArguments,
              OpenAIJsonContext.defaultValue.iDictionaryStringObject,
            )
            : null;
    return realtimeConversationItem(
            [functionCallContent(
              funcCallItem.callId ?? string.empty,
              funcCallItem.functionName,
              arguments,
            ) ],
            funcCallItem.id);
  }

  static RealtimeConversationItem mapMessageItem(RealtimeMessageItem messageItem) {
    var contents = List<AContent>();
    if (messageItem.content != null) {
      for (final part in messageItem.content) {
        if (part is RealtimeInputTextMessageContentPart) {
          final textPart = part as RealtimeInputTextMessageContentPart;
          contents.add(textContent(textPart.text));
        } else if (part is RealtimeOutputTextMessageContentPart) {
          final outputTextPart = part as RealtimeOutputTextMessageContentPart;
          contents.add(textContent(outputTextPart.text));
        } else if (part is RealtimeInputAudioMessageContentPart) {
          final audioPart = part as RealtimeInputAudioMessageContentPart;
          if (audioPart.audioBytes != null) {
            contents.add(dataContent('data:audio/pcm;base64,${Convert.toBase64String(audioPart.audioBytes.toArray())}'));
          }
        } else if (part is RealtimeOutputAudioMessageContentPart) {
          final outputAudioPart = part as RealtimeOutputAudioMessageContentPart;
          if (outputAudioPart.transcript != null) {
            contents.add(textContent(outputAudioPart.transcript));
          }
          if (outputAudioPart.audioBytes != null) {
            contents.add(dataContent('data:audio/pcm;base64,${Convert.toBase64String(outputAudioPart.audioBytes.toArray())}'));
          }
        } else if (part is Sdk.realtimeInputImageMessageContentPart imagePart && imagePart.imageUri != null) {
          contents.add(dataContent(imagePart.imageUri.toString()));
        }
      }
    }
    var role = messageItem.role == Sdk.realtimeMessageRole.assistant ? ChatRole.assistant
            : messageItem.role == Sdk.realtimeMessageRole.user ? ChatRole.user
            : messageItem.role == Sdk.realtimeMessageRole.system ? ChatRole.system
            : null;
    return realtimeConversationItem(contents, messageItem.id, role);
  }

  static RealtimeConversationItem mapMcpToolCallItem(RealtimeMcpToolCallItem mcpItem) {
    var callId = mcpItem.id ?? string.empty;
    var arguments = null;
    if (mcpItem.toolArguments != null) {
      var argsJson = mcpItem.toolArguments.toString();
      if (!string.isNullOrEmpty(argsJson)) {
        arguments = JsonSerializer.deserialize(
          argsJson,
          OpenAIJsonContext.defaultValue.iDictionaryStringObject,
        );
      }
    }
    var contents = List<AContent>();
    if (mcpItem.toolOutput != null|| mcpItem.error != null) {
      var resultContent = mcpItem.error != null
                ? errorContent(mcpItem.error.message)
                : textContent(mcpItem.toolOutput);
      contents.add(mcpServerToolResultContent(callId));
    }
    return realtimeConversationItem(contents, mcpItem.id);
  }

  static RealtimeConversationItem mapMcpApprovalRequestItem(RealtimeMcpToolCallApprovalRequestItem approvalItem) {
    var approvalId = approvalItem.id ?? string.empty;
    var arguments = null;
    if (approvalItem.toolArguments != null) {
      var argsJson = approvalItem.toolArguments.toString();
      if (!string.isNullOrEmpty(argsJson)) {
        arguments = JsonSerializer.deserialize(
          argsJson,
          OpenAIJsonContext.defaultValue.iDictionaryStringObject,
        );
      }
    }
    var toolCall = mcpServerToolCallContent(
      approvalId,
      approvalItem.toolName ?? string.empty,
      approvalItem.serverLabel,
    );
    return realtimeConversationItem(
            [toolApprovalRequestContent(approvalId, toolCall)],
            approvalItem.id);
  }

  static RealtimeConversationItem mapMcpToolDefinitionListItem(RealtimeMcpToolDefinitionListItem toolListItem) {
    var contents = List<AContent>();
    for (final toolDef in toolListItem.toolDefinitions) {
      if (toolDef.name != null) {
        contents.add(mcpServerToolCallContent(toolDef.name, toolDef.name, toolListItem.serverLabel));
      }
    }
    return realtimeConversationItem(contents, toolListItem.id);
  }

  static UsageDetails? mapUsageDetails(RealtimeResponseUsage? usage) {
    if (usage == null) {
      return null;
    }
    var details = usageDetails();
    if (usage.inputTokenDetails is { } inputDetails) {
      details.inputAudioTokenCount = inputDetails.audioTokenCount ?? 0;
      details.inputTextTokenCount = inputDetails.textTokenCount ?? 0;
    }
    if (usage.outputTokenDetails is { } outputDetails) {
      details.outputAudioTokenCount = outputDetails.audioTokenCount ?? 0;
      details.outputTextTokenCount = outputDetails.textTokenCount ?? 0;
    }
    return details;
  }

  static RealtimeAudioFormat? mapSdkAudioFormat(RealtimeAudioFormat? format) {
    return format switch
    {
        Sdk.realtimePcmAudioFormat (pcm) => realtimeAudioFormat("audio/pcm", pcm.rate),
        Sdk.realtimePcmuAudioFormat => realtimeAudioFormat("audio/pcmu", 8000),
        Sdk.realtimePcmaAudioFormat => realtimeAudioFormat("audio/pcma", 8000),
        (_) => null,
    };
  }
}
