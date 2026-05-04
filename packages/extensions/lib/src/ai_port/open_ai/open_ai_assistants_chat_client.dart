import '../abstractions/chat_completion/auto_chat_tool_mode.dart';
import '../abstractions/chat_completion/chat_client.dart';
import '../abstractions/chat_completion/chat_client_metadata.dart';
import '../abstractions/chat_completion/chat_message.dart';
import '../abstractions/chat_completion/chat_options.dart';
import '../abstractions/chat_completion/chat_response_format_json.dart';
import '../abstractions/chat_completion/chat_response_format_text.dart';
import '../abstractions/chat_completion/chat_response_update.dart';
import '../abstractions/chat_completion/chat_role.dart';
import '../abstractions/chat_completion/none_chat_tool_mode.dart';
import '../abstractions/chat_completion/required_chat_tool_mode.dart';
import '../abstractions/contents/ai_content.dart';
import '../abstractions/contents/citation_annotation.dart';
import '../abstractions/contents/data_content.dart';
import '../abstractions/contents/function_result_content.dart';
import '../abstractions/contents/hosted_file_content.dart';
import '../abstractions/contents/text_content.dart';
import '../abstractions/contents/uri_content.dart';
import '../abstractions/contents/usage_content.dart';
import '../abstractions/functions/ai_function_declaration.dart';
import '../abstractions/tools/hosted_code_interpreter_tool.dart';
import '../abstractions/tools/hosted_file_search_tool.dart';
import 'open_ai_client_extensions.dart';
import 'open_ai_json_context.dart';

/// Represents an [ChatClient] for an OpenAI [AssistantClient].
class OpenAAssistantsChatClient implements ChatClient {
  /// Initializes a new instance of the [OpenAIAssistantsChatClient] class for
  /// the specified [AssistantClient].
  OpenAAssistantsChatClient(
    AssistantClient assistantClient,
    String? defaultThreadId,
    {String? assistantId = null, Assistant? assistant = null, },
  ) :
      _client = Throw.ifNull(assistantClient),
      _assistantId = Throw.ifNullOrWhitespace(assistantId),
      _defaultThreadId = defaultThreadId,
      _metadata = new("openai", assistantClient.endpoint);

  /// The underlying [AssistantClient].
  final AssistantClient _client;

  /// Metadata for the client.
  final ChatClientMetadata _metadata;

  /// The ID of the agent to use.
  final String _assistantId;

  /// The thread ID to use if none is supplied in [ConversationId].
  final String? _defaultThreadId;

  /// List of tools associated with the assistant.
  List<ToolDefinition>? _assistantTools;

  @override
  Object? getService(Type serviceType, {Object? serviceKey, }) {
    return serviceType == null ? throw argumentNullException(nameof(serviceType)) :
        serviceKey != null ? null :
        serviceType == typeof(ChatClientMetadata) ? _metadata :
        serviceType == typeof(AssistantClient) ? _client :
        serviceType.isInstanceOfType(this) ? this :
        null;
  }

  @override
  Future<ChatResponse> getResponse(
    Iterable<ChatMessage> messages,
    {ChatOptions? options, CancellationToken? cancellationToken, },
  ) {
    return getStreamingResponseAsync(
      messages,
      options,
      cancellationToken,
    ) .toChatResponseAsync(cancellationToken);
  }

  @override
  Stream<ChatResponseUpdate> getStreamingResponse(
    Iterable<ChatMessage> messages,
    {ChatOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    _ = Throw.ifNull(messages);
    // Extract necessary state from messages and options.
        (
          RunCreationOptions runOptions,
          ToolResources? toolResources,
          List<FunctionResultContent>? toolResults,
        ) = await createRunOptionsAsync(messages, options, cancellationToken).configureAwait(false);
    var threadId = options?.conversationId ?? _defaultThreadId;
    var threadRun = null;
    if (threadId != null) {
      for (final run in _client.getRunsAsync(
                threadId,
                runCollectionOptions(),
                cancellationToken: cancellationToken).configureAwait(false)) {
        if (run.status != RunStatus.completed && run.status != RunStatus.cancelled && run.status != RunStatus.failed && run.status != RunStatus.expired) {
          threadRun = run;
        }
        break;
      }
    }
    // Submit the request.
        IAsyncEnumerable<StreamingUpdate> updates;
    List<ToolOutput>? toolOutputs;
    if (threadRun != null &&
            convertFunctionResultsToToolOutput(toolResults) is { } toolRunId &&
            toolRunId == threadRun.id) {
      // There's an active run and, critically, we have tool results to submit for that exact run, so submit the results and continue streaming.
            // This is going to ignore any additional messages in the run options, as we are only submitting tool outputs,
            // but there doesn't appear to be a way to submit additional messages, and having such additional messages is rare.
            updates = _client.submitToolOutputsToRunStreamingAsync(
              threadRun.threadId,
              threadRun.id,
              toolOutputs,
              cancellationToken,
            );
    } else {
      if (threadId == null) {
        var threadCreationOptions = new()
                {
                    ToolResources = toolResources,
                };
        for (final message in runOptions.additionalMessages) {
          threadCreationOptions.initialMessages.add(message);
        }
        runOptions.additionalMessages.clear();
        var thread = await _client.createThreadAsync(
          threadCreationOptions,
          cancellationToken,
        ) .configureAwait(false);
        threadId = thread.value.id;
      } else if (threadRun != null) {
        // There was an active run; we need to cancel it before starting a new run.
                _ = await _client.cancelRunAsync(
                  threadId,
                  threadRun.id,
                  cancellationToken,
                ) .configureAwait(false);
        threadRun = null;
      }
      // Now create a new run and stream the results.
            updates = _client.createRunStreamingAsync(
                threadId: threadId,
                _assistantId,
                runOptions,
                cancellationToken);
    }
    var responseId = null;
    for (final update in updates.configureAwait(false)) {
      switch (update) {
        case ThreadUpdate tu:
        threadId ??= tu.value.id;
        /* TODO: unsupported node kind "unknown" */
        // goto default;
        case RunUpdate ru:
        threadId ??= ru.value.threadId;
        responseId ??= ru.value.id;
        var ruUpdate = new()
                    {
                        AuthorName = _assistantId,
                        ConversationId = threadId,
                        CreatedAt = ru.value.createdAt,
                        MessageId = responseId,
                        ModelId = ru.value.model,
                        RawRepresentation = ru,
                        ResponseId = responseId,
                        Role = ChatRole.assistant,
                    };
        if (ru.value.usage is { } usage) {
          ruUpdate.contents.add(usageContent(new()));
        }
        if (ru is RequiredActionUpdate rau && rau.toolCallId is string toolCallId && rau.functionName is string) {
          final functionName = ru is RequiredActionUpdate rau && rau.toolCallId is string toolCallId && rau.functionName as string;
          var fcc = OpenAIClientExtensions.parseCallContent(
                            rau.functionArguments,
                            JsonSerializer.serialize(
                              [ru.value.id, toolCallId],
                              OpenAIJsonContext.defaultValue.stringArray,
                            ),
                            functionName);
          fcc.rawRepresentation = ru;
          ruUpdate.contents.add(fcc);
        }
        yield ruUpdate;
        case RunStepDetailsUpdate details:
        if (!string.isNullOrEmpty(details.codeInterpreterInput)) {
          var hcitcc = new(details.toolCallId)
                        {
                            Inputs = [dataContent(
                              Encoding.utF8.getBytes(details.codeInterpreterInput),
                              OpenAIClientExtensions.pythonMediaType,
                            ) ],
                            RawRepresentation = details,
                        };
          yield chatResponseUpdate(ChatRole.assistant, [hcitcc]);
        }
        if (details.codeInterpreterOutputs is { Count: > 0 }) {
          var hcitrc = new(details.toolCallId)
                        {
                            RawRepresentation = details,
                        };
          for (final output in details.codeInterpreterOutputs) {
            if (output.imageFileId != null) {
              (hcitrc.outputs ??= []).add(hostedFileContent(output.imageFileId));
            }
            if (output.logs is string) {
              final logs = output.logs as string;
              (hcitrc.outputs ??= []).add(textContent(logs));
            }
          }
          yield chatResponseUpdate(ChatRole.assistant, [hcitrc]);
        }
        case MessageContentUpdate mcu:
        var textUpdate = new(
          mcu.role == MessageRole.user ? ChatRole.user : ChatRole.assistant,
          mcu.text,
        )
                    {
                        AuthorName = _assistantId,
                        ConversationId = threadId,
                        MessageId = responseId,
                        RawRepresentation = mcu,
                        ResponseId = responseId,
                    };
        if (mcu.textAnnotation is { } tau) {
          var fileId = null;
          var toolName = null;
          if (!string.isNullOrWhiteSpace(tau.inputFileId)) {
            fileId = tau.inputFileId;
            toolName = "file_search";
          } else if (!string.isNullOrWhiteSpace(tau.outputFileId)) {
            fileId = tau.outputFileId;
            toolName = "code_interpreter";
          }
          if (fileId != null) {
            if (textUpdate.contents.count == 0) {
              // In case a chunk doesn't have text content, create one with empty text to hold the annotation.
                                textUpdate.contents.add(textContent(string.empty));
            }
            (((TextContent)textUpdate.contents[0]).annotations ??= []).add(citationAnnotation()],
                                FileId = fileId,
                                ToolName = toolName,
                            });
        }
      }
      yield textUpdate;
      default:
      yield new()
                    {
                        AuthorName = _assistantId,
                        ConversationId = threadId,
                        MessageId = responseId,
                        RawRepresentation = update,
                        ResponseId = responseId,
                        Role = ChatRole.assistant,
                    };
    }
  }
}
void dispose() {

 }
/// Converts an Extensions function to an OpenAI assistants function tool.
static FunctionToolDefinition toOpenAIAssistantsFunctionToolDefinition(
  AFunctionDeclaration aiFunction,
  {ChatOptions? options, },
) {
var strict = OpenAIClientExtensions.hasStrict(aiFunction.additionalProperties) ??
            OpenAIClientExtensions.hasStrict(options?.additionalProperties);
return functionToolDefinition(aiFunction.name);
 }
/// Creates the [RunCreationOptions] to use for the request and extracts any
/// function result contents that need to be submitted as tool results.
Future<RunCreationOptionsRunOptions, ToolResourcesResources, ListFunctionResultContentToolResults> createRunOptions(
  Iterable<ChatMessage> messages,
  ChatOptions? options,
  CancellationToken cancellationToken,
) async  {
var runOptions = options?.rawRepresentationFactory?.invoke(this) as RunCreationOptions ??
            new();
var resources = null;
if (options != null) {
  runOptions.maxOutputTokenCount ??= options.maxOutputTokens;
  runOptions.modelOverride ??= options.modelId;
  runOptions.nucleusSamplingFactor ??= options.topP;
  runOptions.temperature ??= options.temperature;
  runOptions.allowParallelToolCalls ??= options.allowMultipleToolCalls;
  if (options.tools is { Count: > 0 } tools) {
    var toolsOverride = new(ToolDefinitionNameEqualityComparer.instance);
    if (runOptions.toolsOverride.count == 0) {
      if (_assistantTools == null) {
        var assistant = await _client.getAssistantAsync(
          _assistantId,
          cancellationToken,
        ) .configureAwait(false);
        _assistantTools = assistant.value.tools;
      }
      toolsOverride.unionWith(_assistantTools);
    }
    for (final tool in tools) {
      switch (tool) {
        case AIFunctionDeclaration aiFunction:
          _ = toolsOverride.add(toOpenAIAssistantsFunctionToolDefinition(aiFunction, options));
        case HostedCodeInterpreterTool codeInterpreterTool:
          var interpreterToolDef = ToolDefinition.createCodeInterpreter();
          _ = toolsOverride.add(interpreterToolDef);
          if (codeInterpreterTool.inputs?.count is > 0) {
            var threadInitializationMessage = null;
            for (final input in codeInterpreterTool.inputs) {
              if (input is HostedFileContent) {
                  final hostedFile = input as HostedFileContent;
                  threadInitializationMessage ??= new(
                    MessageRole.user,
                    [MessageContent.fromText("attachments")],
                  );
                  threadInitializationMessage.attachments.add(new(hostedFile.fileId, [interpreterToolDef]));
                }
            }
            if (threadInitializationMessage != null) {
              runOptions.additionalMessages.add(threadInitializationMessage);
            }
          }
        case HostedFileSearchTool fileSearchTool:
          var fst = ToolDefinition.createFileSearch(fileSearchTool.maximumResultCount);
          fst.rankingOptions = fileSearchTool.getProperty<FileSearchRankingOptions>(nameof(FileSearchToolDefinition.rankingOptions));
          _ = toolsOverride.add(fst);
          if (fileSearchTool.inputs is { Count: > 0 } fileSearchInputs) {
            for (final input in fileSearchInputs) {
              if (input is HostedVectorStoreContent) {
                  final file = input as HostedVectorStoreContent;
                  (resources ??= new()).fileSearch ??= new();
                  resources.fileSearch.vectorStoreIds.add(file.vectorStoreId);
                }
            }
          }
      }
    }
    for (final tool in toolsOverride) {
      runOptions.toolsOverride.add(tool);
    }
  }

  if (runOptions.toolConstraint == null) {
    switch (options.toolMode) {
      case NoneChatToolMode:
        runOptions.toolConstraint = ToolConstraint.none;
      case AutoChatToolMode:
        runOptions.toolConstraint = ToolConstraint.auto;
      case RequiredChatToolMode required:
        runOptions.toolConstraint = toolConstraint(ToolDefinition.createFunction(functionName));
      case RequiredChatToolMode required:
        runOptions.toolConstraint = ToolConstraint.required;
    }
  }

  if (runOptions.responseFormat == null) {
    switch (options.responseFormat) {
      case ChatResponseFormatText:
        runOptions.responseFormat = AssistantResponseFormat.createTextFormat();
      case ChatResponseFormatJson jsonFormat:
        runOptions.responseFormat = AssistantResponseFormat.createJsonSchemaFormat(
                            jsonFormat.schemaName,
                            BinaryData.fromBytes(JsonSerializer.serializeToUtf8Bytes(jsonSchema, OpenAIJsonContext.defaultValue.jsonElement)),
                            jsonFormat.schemaDescription,
                            OpenAIClientExtensions.hasStrict(options.additionalProperties));
      case ChatResponseFormatJson jsonFormat:
        runOptions.responseFormat = AssistantResponseFormat.createJsonObjectFormat();
    }
  }
}
var instructions = null;
/* TODO: unsupported node kind "unknown" */
// void AppendSystemInstructions(string? toAppend)
//         {
//             if (!string.IsNullOrEmpty(toAppend))
//             {
//                 if (instructions is null)
//                 {
//                     instructions = new(toAppend);
//                 }
//                 else
//                 {
//                     _ = instructions.AppendLine().AppendLine(toAppend);
//                 }
//             }
//         }
appendSystemInstructions(runOptions.additionalInstructions);
appendSystemInstructions(options?.instructions);
var functionResults = null;
for (final chatMessage in messages) {
  var messageContents = [];
  if (chatMessage.role == ChatRole.system ||
                chatMessage.role == OpenAIClientExtensions.chatRoleDeveloper) {
    for (final textContent in chatMessage.contents.ofType<TextContent>()) {
      appendSystemInstructions(textContent.text);
    }
    continue;
  }

  for (final content in chatMessage.contents) {
    switch (content) {
      case AIContent:
        messageContents.add(rawRep);
      case TextContent text:
        messageContents.add(MessageContent.fromText(text.text));
      case UriContent image:
        messageContents.add(MessageContent.fromImageUri(image.uri));
      case FunctionResultContent result:
        (functionResults ??= []).add(result);
    }
  }

  if (messageContents.count > 0) {
    runOptions.additionalMessages.add(threadInitializationMessage(
                    chatMessage.role == ChatRole.assistant ? MessageRole.assistant : MessageRole.user,
                    messageContents));
  }
}
runOptions.additionalInstructions = instructions?.toString();
return (runOptions, resources, functionResults);
 }
/// Convert [FunctionResultContent] instances to [ToolOutput] instances.
///
/// Returns: The run ID associated with the corresponding function call
/// requests.
///
/// [toolResults] The tool results to process.
///
/// [toolOutputs] The generated list of tool outputs, if any could be created.
static (
  String?,
  List<ToolOutput>??,
) convertFunctionResultsToToolOutput(List<FunctionResultContent>? toolResults) {
var toolOutputs = null;
var runId = null;
toolOutputs = null;
if (toolResults?.count > 0) {
  for (final frc in toolResults) {
      var runAndCallIDs;
      try {
            runAndCallIDs = JsonSerializer.deserialize(
              frc.callId,
              OpenAIJsonContext.defaultValue.stringArray,
            );
          } catch (e, s) {
            continue;
          }
      if (runAndCallIDs == null ||
                          runAndCallIDs.length != 2 ||
                          string.isNullOrWhiteSpace(runAndCallIDs[0]) || // run ID
                          string.isNullOrWhiteSpace(runAndCallIDs[1]) || // call id(runId != null && runId != runAndCallIDs[0])) {
            continue;
          }
      runId = runAndCallIDs[0];
      (toolOutputs ??= []).add(new(runAndCallIDs[1], frc.result?.toString() ?? string.empty));
    }
}
return (runId, toolOutputs);
 }
 }
/// Provides the same behavior as [Default], except for
/// [FunctionToolDefinition] it compares names so that two function tool
/// definitions with the same name compare equally.
class ToolDefinitionNameEqualityComparer implements EqualityComparer<ToolDefinition> {
  ToolDefinitionNameEqualityComparer();

  static final ToolDefinitionNameEqualityComparer instance;

  bool equals(ToolDefinition? x, ToolDefinition? y, ) {
    return x is FunctionToolDefinition xFtd && y is FunctionToolDefinition yFtd ? xFtd.functionName.equals(
      yFtd.functionName,
      StringComparison.ordinal,
    ) : 
            EqualityComparer<ToolDefinition?>.defaultValue.equals(x, y);
  }

  @override
  int getHashCode(ToolDefinition obj) {
    return obj is FunctionToolDefinition ftd ? ftd.functionName.getHashCode(StringComparison.ordinal) :
            EqualityComparer<ToolDefinition>.defaultValue.getHashCode(obj);
  }
}
