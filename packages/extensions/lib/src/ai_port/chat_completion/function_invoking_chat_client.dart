import '../../../../../lib/func_typedefs.dart';
import '../abstractions/chat_completion/chat_client.dart';
import '../abstractions/chat_completion/chat_message.dart';
import '../abstractions/chat_completion/chat_options.dart';
import '../abstractions/chat_completion/chat_response_update.dart';
import '../abstractions/chat_completion/chat_role.dart';
import '../abstractions/chat_completion/delegating_chat_client.dart';
import '../abstractions/chat_completion/required_chat_tool_mode.dart';
import '../abstractions/contents/ai_content.dart';
import '../abstractions/contents/function_call_content.dart';
import '../abstractions/contents/function_result_content.dart';
import '../abstractions/contents/tool_approval_request_content.dart';
import '../abstractions/contents/tool_approval_response_content.dart';
import '../abstractions/functions/ai_function.dart';
import '../abstractions/functions/ai_function_declaration.dart';
import '../abstractions/functions/approval_required_ai_function.dart';
import '../abstractions/tools/ai_tool.dart';
import '../abstractions/usage_details.dart';
import '../common/function_invocation_helpers.dart';
import '../common/function_invocation_logger.dart';
import '../common/function_invocation_processor.dart';
import '../open_telemetry_consts.dart';
import 'function_invocation_context.dart';
import 'open_telemetry_chat_client.dart';

/// A delegating chat client that invokes functions defined on [ChatOptions].
/// Include this in a chat pipeline to resolve function calls automatically.
///
/// Remarks: When this client receives a [FunctionCallContent] in a chat
/// response from its inner [ChatClient], it responds by invoking the
/// corresponding [AIFunction] defined in [Tools] (or in [AdditionalTools]),
/// producing a [FunctionResultContent] that it sends back to the inner
/// client. This loop is repeated until there are no more function calls to
/// make, or until another stop condition is met, such as hitting
/// [MaximumIterationsPerRequest]. If a requested function is an
/// [AIFunctionDeclaration] but not an [AIFunction], the
/// [FunctionInvokingChatClient] will not attempt to invoke it, and instead
/// allow that [FunctionCallContent] to pass back out to the caller. It is
/// then that caller's responsibility to create the appropriate
/// [FunctionResultContent] for that call and send it back as part of a
/// subsequent request. Further, if a requested function is an
/// [ApprovalRequiredAIFunction], the [FunctionInvokingChatClient] will not
/// attempt to invoke it directly. Instead, it will replace that
/// [FunctionCallContent] with a [ToolApprovalRequestContent] that wraps the
/// [FunctionCallContent] and indicates that the function requires approval
/// before it can be invoked. The caller is then responsible for responding to
/// that approval request by sending a corresponding
/// [ToolApprovalResponseContent] in a subsequent request. The
/// [FunctionInvokingChatClient] will then process that approval response and
/// invoke the function as appropriate. Due to the nature of interactions with
/// an underlying [ChatClient], if any [FunctionCallContent] is received for a
/// function that requires approval, all received [FunctionCallContent] in
/// that same response will also require approval, even if they were not
/// [ApprovalRequiredAIFunction] instances. If this is a concern, consider
/// requesting that multiple tool call requests not be made in a single
/// response, by setting [AllowMultipleToolCalls] to `false`. A
/// [FunctionInvokingChatClient] instance is thread-safe for concurrent use so
/// long as the [AIFunction] instances employed as part of the supplied
/// [ChatOptions] are also safe. The [AllowConcurrentInvocation] property can
/// be used to control whether multiple function invocation requests as part
/// of the same request are invocable concurrently, but even with that set to
/// `false` (the default), multiple concurrent requests to this same instance
/// and using the same tools could result in those tools being used
/// concurrently (one per request). For example, a function that accesses the
/// HttpContext of a specific ASP.NET web request should only be used as part
/// of a single [ChatOptions] at a time, and only with
/// [AllowConcurrentInvocation] set to `false`, in case the inner client
/// decided to issue multiple invocation requests to that same function.
class FunctionInvokingChatClient extends DelegatingChatClient {
  /// Initializes a new instance of the [FunctionInvokingChatClient] class.
  ///
  /// [innerClient] The underlying [ChatClient], or the next instance in a chain
  /// of clients.
  ///
  /// [loggerFactory] An [LoggerFactory] to use for logging information about
  /// function invocation.
  ///
  /// [functionInvocationServices] An optional [ServiceProvider] to use for
  /// resolving services required by the [AIFunction] instances being invoked.
  FunctionInvokingChatClient(
    ChatClient innerClient,
    {LoggerFactory? loggerFactory = null, ServiceProvider? functionInvocationServices = null, },
  ) :
      _logger = (ILogger?)loggerFactory?.createLogger<FunctionInvokingChatClient>() ?? NullLogger.instance,
      _activitySource = innerClient.getService<ActivitySource>(),
      functionInvocationServices = functionInvocationServices;

  /// The [FunctionInvocationContext] for the current function invocation.
  static final AsyncLocal<FunctionInvocationContext?> _currentContext;

  /// Gets the [ServiceProvider] specified when constructing the
  /// [FunctionInvokingChatClient], if any.
  final ServiceProvider? functionInvocationServices;

  /// The logger to use for logging information about function invocation.
  final Logger _logger;

  /// The [ActivitySource] to use for telemetry.
  ///
  /// Remarks: This component does not own the instance and should not dispose
  /// it.
  final ActivitySource? _activitySource;

  /// Gets or sets the [FunctionInvocationContext] for the current function
  /// invocation.
  ///
  /// Remarks: This value flows across async calls.
  static FunctionInvocationContext? currentContext;

  /// Gets or sets a value indicating whether detailed exception information
  /// should be included in the chat history when calling the underlying
  /// [ChatClient].
  ///
  /// Remarks: Setting the value to `false` prevents the underlying language
  /// model from disclosing raw exception details to the end user, since it
  /// doesn't receive that information. Even in this case, the raw [Exception]
  /// object is available to application code by inspecting the [Exception]
  /// property. Setting the value to `true` can help the underlying [ChatClient]
  /// bypass problems on its own, for example by retrying the function call with
  /// different arguments. However it might result in disclosing the raw
  /// exception information to external users, which can be a security concern
  /// depending on the application scenario. Changing the value of this property
  /// while the client is in use might result in inconsistencies as to whether
  /// detailed errors are provided during an in-flight request.
  bool includeDetailedErrors;

  /// Gets or sets a value indicating whether to allow concurrent invocation of
  /// functions.
  ///
  /// Remarks: An individual response from the inner client might contain
  /// multiple function call requests. By default, such function calls are
  /// processed serially. Set [AllowConcurrentInvocation] to `true` to enable
  /// concurrent invocation such that multiple function calls can execute in
  /// parallel.
  bool allowConcurrentInvocation;

  /// Gets or sets the maximum number of iterations per request.
  ///
  /// Remarks: Each request to this [FunctionInvokingChatClient] might end up
  /// making multiple requests to the inner client. Each time the inner client
  /// responds with a function call request, this client might perform that
  /// invocation and send the results back to the inner client in a new request.
  /// This property limits the number of times such a roundtrip is performed.
  /// The value must be at least one, as it includes the initial request.
  /// Changing the value of this property while the client is in use might
  /// result in inconsistencies as to how many iterations are allowed for an
  /// in-flight request.
  int maximumIterationsPerRequest = 40;

  /// Gets or sets the maximum number of consecutive iterations that are allowed
  /// to fail with an error.
  ///
  /// Remarks: When function invocations fail with an exception, the
  /// [FunctionInvokingChatClient] continues to make requests to the inner
  /// client, optionally supplying exception information (as controlled by
  /// [IncludeDetailedErrors]). This allows the [ChatClient] to recover from
  /// errors by trying other function parameters that might succeed. However, in
  /// case function invocations continue to produce exceptions, this property
  /// can be used to limit the number of consecutive failing attempts. When the
  /// limit is reached, the exception will be rethrown to the caller. If the
  /// value is set to zero, all function calling exceptions immediately
  /// terminate the function invocation loop and the exception will be rethrown
  /// to the caller. Changing the value of this property while the client is in
  /// use might result in inconsistencies as to how many iterations are allowed
  /// for an in-flight request.
  int maximumConsecutiveErrorsPerRequest = 3;

  /// Gets or sets a collection of additional tools the client is able to
  /// invoke.
  ///
  /// Remarks: These will not impact the requests sent by the
  /// [FunctionInvokingChatClient], which will pass through the [Tools]
  /// unmodified. However, if the inner client requests the invocation of a tool
  /// that was not in [Tools], this [AdditionalTools] collection will also be
  /// consulted to look for a corresponding tool to invoke. This is useful when
  /// the service might have been preconfigured to be aware of certain tools
  /// that aren't also sent on each individual request.
  List<ATool>? additionalTools;

  /// Gets or sets a value indicating whether a request to call an unknown
  /// function should terminate the function calling loop.
  ///
  /// Remarks: When `false`, call requests to any tools that aren't available to
  /// the [FunctionInvokingChatClient] will result in a response message
  /// automatically being created and returned to the inner client stating that
  /// the tool couldn't be found. This behavior can help in cases where a model
  /// hallucinates a function, but it's problematic if the model has been made
  /// aware of the existence of tools outside of the normal mechanisms, and
  /// requests one of those. [AdditionalTools] can be used to help with that.
  /// But if instead the consumer wants to know about all function call requests
  /// that the client can't handle, [TerminateOnUnknownCalls] can be set to
  /// `true`. Upon receiving a request to call a function that the
  /// [FunctionInvokingChatClient] doesn't know about, it will terminate the
  /// function calling loop and return the response, leaving the handling of the
  /// function call requests to the consumer of the client. [AITool]s that the
  /// [FunctionInvokingChatClient] is aware of (for example, because they're in
  /// [Tools] or [AdditionalTools]) but that aren't [AIFunction]s aren't
  /// considered unknown, just not invocable. Any requests to a non-invocable
  /// tool will also result in the function calling loop terminating, regardless
  /// of [TerminateOnUnknownCalls].
  bool terminateOnUnknownCalls;

  /// Gets or sets a delegate used to invoke [AIFunction] instances.
  ///
  /// Remarks: By default, the protected [CancellationToken)] method is called
  /// for each [AIFunction] to be invoked, invoking the instance and returning
  /// its result. If this delegate is set to a non-`null` value,
  /// [CancellationToken)] will replace its normal invocation with a call to
  /// this delegate, enabling this delegate to assume all invocation handling of
  /// the function.
  Func2<FunctionInvocationContext, CancellationToken, Future<Object?>>? functionInvoker;

  /// Gets the function invocation processor, creating it lazily.
  FunctionInvocationProcessor get processor {
    return field ??= functionInvocationProcessor(
        _logger,
        _activitySource,
        InvokeFunctionAsync,
        (invokeAgentActivity) =>
            invokeAgentActivity != null
                ? invokeAgentActivity.getCustomProperty(OpenTelemetryChatClient.sensitiveDataEnabledCustomKey) as string is OpenTelemetryChatClient.sensitiveDataEnabledTrueValue
                : InnerClient.getService<OpenTelemetryChatClient>()?.enableSensitiveData is true);
  }

  @override
  Future<ChatResponse> getResponse(
    Iterable<ChatMessage> messages,
    {ChatOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    _ = Throw.ifNull(messages);
    var activity = FunctionInvocationHelpers.currentActivityIsInvokeAgent ? null : _activitySource?.startActivity(OpenTelemetryConsts.genAI.orchestrateToolsName);
    var originalMessages = [.. messages];
    messages = originalMessages;
    var augmentedHistory = null;
    var response = null;
    var responseMessages = null;
    var totalUsage = null;
    var functionCallContents = null;
    var lastIterationHadConversationId = false;
    var consecutiveErrorCount = 0;
    var anyToolsRequireApproval = false;
    if (hasAnyApprovalContent(originalMessages)) {
      // A previous turn may have translated FunctionCallContents from the inner client into approval requests sent back to the caller,
            // for any AIFunctions that were actually ApprovalRequiredAIFunctions. If the incoming chat messages include responses to those
            // approval requests, we need to process them now. This entails removing these manufactured approval requests from the chat message
            // list and replacing them with the appropriate FunctionCallContents and FunctionResultContents that would have been generated if
            // the inner client had returned them directly.
            (responseMessages, var notInvokedApprovals) = processFunctionApprovalResponses(
                originalMessages, !string.isNullOrWhiteSpace(options?.conversationId), toolMessageId: null, functionCallContentFallbackMessageId: null);
      (
        IList<ChatMessage>? invokedApprovedFunctionApprovalResponses,
        bool shouldTerminate,
        consecutiveErrorCount,
      ) =
                await invokeApprovedFunctionApprovalResponsesAsync(
                  notInvokedApprovals,
                  originalMessages,
                  options,
                  consecutiveErrorCount,
                  isStreaming: false,
                  cancellationToken,
                );
      if (invokedApprovedFunctionApprovalResponses != null) {
        // Add any generated FRCs to the list we'll return to callers as part of the next response.
                (responseMessages ??= []).addRange(invokedApprovedFunctionApprovalResponses);
      }
      if (shouldTerminate) {
        return chatResponse(responseMessages);
      }
    }
    for (var iteration = 0; ; iteration++) {
      functionCallContents?.clear();
      if (iteration >= maximumIterationsPerRequest) {
        logMaximumIterationsReached(maximumIterationsPerRequest);
        prepareOptionsForLastIteration(ref options);
      }
      // Make the call to the inner client.
            response = await base.getResponseAsync(messages, options, cancellationToken);
      if (response == null) {
        Throw.invalidOperationException('The inner ${nameof(IChatClient)} returned a null ${nameof(ChatResponse)}.');
      }
      // Before we do any function execution, mark any FunctionCallContent as InformationalOnly if the
            // response also contains a matching FunctionResultContent, as that means the server already handled the call.
            markServerHandledFunctionCalls(response.messages);
      // Before we do any function execution, make sure that any functions that require approval have been turned into
            // approval requests so that they don't get executed here. We recompute anyToolsRequireApproval on each iteration
            // because a function may have modified ChatOptions.tools.
            anyToolsRequireApproval = anyToolsRequireApproval(options?.tools, additionalTools);
      if (anyToolsRequireApproval) {
        response.messages = replaceFunctionCallsWithApprovalRequests(
          response.messages,
          options?.tools,
          additionalTools,
        );
      }
      var requiresFunctionInvocation = iteration < maximumIterationsPerRequest &&
                copyFunctionCalls(response.messages, ref functionCallContents);
      if (!requiresFunctionInvocation && iteration == 0) {
        if (responseMessages is { Count: > 0 }) {
          responseMessages.addRange(response.messages);
          response.messages = responseMessages;
        }
        return response;
      }
      // Track aggregate details from the response, including all of the response messages and usage details.
            (responseMessages ??= []).addRange(response.messages);
      if (response.usage != null) {
        if (totalUsage != null) {
          totalUsage.add(response.usage);
        } else {
          totalUsage = response.usage;
        }
      }
      if (!requiresFunctionInvocation ||
                shouldTerminateLoopBasedOnHandleableFunctions(functionCallContents, options)) {
        break;
      }
      // Prepare the history for the next iteration.
            fixupHistories(
              originalMessages,
              ref messages,
              ref augmentedHistory,
              response,
              responseMessages,
              ref lastIterationHadConversationId,
            );
      var modeAndMessages = await processFunctionCallsAsync(
        augmentedHistory,
        options,
        functionCallContents!,
        iteration,
        consecutiveErrorCount,
        isStreaming: false,
        cancellationToken,
      );
      responseMessages.addRange(modeAndMessages.messagesAdded);
      consecutiveErrorCount = modeAndMessages.newConsecutiveErrorCount;
      if (modeAndMessages.shouldTerminate) {
        break;
      }
      updateOptionsForNextIteration(ref options, response.conversationId);
    }
    Debug.assertValue(
      responseMessages != null,
      "Expected to only be here if we have response messages.",
    );
    response.messages = responseMessages!;
    response.usage = totalUsage;
    addUsageTags(activity, totalUsage);
    return response;
  }

  @override
  Stream<ChatResponseUpdate> getStreamingResponse(
    Iterable<ChatMessage> messages,
    {ChatOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    _ = Throw.ifNull(messages);
    var activity = FunctionInvocationHelpers.currentActivityIsInvokeAgent ? null : _activitySource?.startActivity(OpenTelemetryConsts.genAI.orchestrateToolsName);
    var totalUsage = activity is { IsAllDataRequested: true } ? new() : null;
    var originalMessages = [.. messages];
    messages = originalMessages;
    var augmentedHistory = null;
    var functionCallContents = null;
    var responseMessages = null;
    var lastIterationHadConversationId = false;
    var updates = [];
    var consecutiveErrorCount = 0;
    var anyToolsRequireApproval = false;
    var toolMessageId = Guid.newGuid().toString("N");
    if (hasAnyApprovalContent(originalMessages)) {
      var functionCallContentFallbackMessageId = Guid.newGuid().toString("N");
      // A previous turn may have translated FunctionCallContents from the inner client into approval requests sent back to the caller,
            // for any AIFunctions that were actually ApprovalRequiredAIFunctions. If the incoming chat messages include responses to those
            // approval requests, we need to process them now. This entails removing these manufactured approval requests from the chat message
            // list and replacing them with the appropriate FunctionCallContents and FunctionResultContents that would have been generated if
            // the inner client had returned them directly.
            var (preDownstreamCallHistory, notInvokedApprovals) = processFunctionApprovalResponses(
                originalMessages, !string.isNullOrWhiteSpace(options?.conversationId), toolMessageId, functionCallContentFallbackMessageId);
      if (preDownstreamCallHistory != null) {
        for (final message in preDownstreamCallHistory) {
          yield convertToolResultMessageToUpdate(
            message,
            options?.conversationId,
            message.messageId,
          );
          if (activity != null) {
            Activity.current = activity;
          }
        }
      }
      // Invoke approved approval responses, which generates some additional FRC wrapped in ChatMessage.
            (
              IList<ChatMessage>? invokedApprovedFunctionApprovalResponses,
              bool shouldTerminate,
              consecutiveErrorCount,
            ) =
                await invokeApprovedFunctionApprovalResponsesAsync(
                  notInvokedApprovals,
                  originalMessages,
                  options,
                  consecutiveErrorCount,
                  isStreaming: true,
                  cancellationToken,
                );
      if (invokedApprovedFunctionApprovalResponses != null) {
        for (final message in invokedApprovedFunctionApprovalResponses) {
          message.messageId = toolMessageId;
          yield convertToolResultMessageToUpdate(
            message,
            options?.conversationId,
            message.messageId,
          );
          if (activity != null) {
            Activity.current = activity;
          }
        }
        if (shouldTerminate) {
          return;
        }
      }
    }
    for (var iteration = 0; ; iteration++) {
      updates.clear();
      functionCallContents?.clear();
      if (iteration >= maximumIterationsPerRequest) {
        logMaximumIterationsReached(maximumIterationsPerRequest);
        prepareOptionsForLastIteration(ref options);
      }
      // Recompute anyToolsRequireApproval on each iteration because a function may have modified ChatOptions.tools.
            anyToolsRequireApproval = anyToolsRequireApproval(options?.tools, additionalTools);
      var approvalRequiredFunctions = null;
      var hasApprovalRequiringFcc = false;
      var lastApprovalCheckedFCCIndex = 0;
      var lastYieldedUpdateIndex = 0;
      for (final update in base.getStreamingResponseAsync(messages, options, cancellationToken)) {
        if (update == null) {
          Throw.invalidOperationException('The inner ${nameof(IChatClient)} streamed a null ${nameof(ChatResponseUpdate)}.');
        }
        updates.add(update);
        _ = copyFunctionCalls(update.contents, ref functionCallContents);
        if (totalUsage != null) {
          var contents = update.contents;
          var contentsCount = contents.count;
          for (var i = 0; i < contentsCount; i++) {
            if (contents[i] is UsageContent) {
              final uc = contents[i] as UsageContent;
              totalUsage.add(uc.details);
            }
          }
        }
        if (anyToolsRequireApproval && approvalRequiredFunctions == null && functionCallContents is { Count: > 0 }) {
          approvalRequiredFunctions =
                        (options?.tools ?? Enumerable.empty<ATool>())
                        .concat(additionalTools ?? Enumerable.empty<ATool>())
                        .where((t) => t.getService<ApprovalRequiredAFunction>() != null)
                        .toArray();
        }
        if (functionCallContents is not { Count: > 0 }) {
          // If there are no function calls to make yet, we can yield the update as-is.
                    lastYieldedUpdateIndex++;
          yield update;
          if (activity != null) {
            Activity.current = activity;
          }
          continue;
        }
        if (approvalRequiredFunctions is not { Length: > 0 }) {
          continue;
        }
        // There are function calls to make, some of which _may_ require approval.
                Debug.assertValue(
                  functionCallContents is { Count: > 0 },
                  "Expected to have function call contents to check for approval requiring functions.",
                );
        Debug.assertValue(
          approvalRequiredFunctions is { Length: > 0 },
          "Expected to have approval requiring functions to check against function call contents.",
        );
        // Check if any of the function call contents in this update requires approval.
                (
                  hasApprovalRequiringFcc,
                  lastApprovalCheckedFCCIndex,
                ) = checkForApprovalRequiringFCC(
                    functionCallContents, approvalRequiredFunctions!, hasApprovalRequiringFcc, lastApprovalCheckedFCCIndex);
        if (hasApprovalRequiringFcc) {
          for (; lastYieldedUpdateIndex < updates.count; lastYieldedUpdateIndex++) {
            var updateToYield = updates[lastYieldedUpdateIndex];
            var updatedContents;
            if (tryReplaceFunctionCallsWithApprovalRequests(updateToYield.contents)) {
              updateToYield.contents = updatedContents;
            }
            yield updateToYield;
            if (activity != null) {
              Activity.current = activity;
            }
          }
          continue;
        }
      }
      // Mark any FunctionCallContent as InformationalOnly if the response also contains a matching
            // FunctionResultContent, as that means the server already handled the call. This is done after the
            // entire stream has been received so that FCC/FRC pairs can be matched across the full set of updates.
            // Any matched FCCs are also removed from functionCallContents so that they won't be invoked locally.
            markServerHandledFunctionCalls(updates, functionCallContents);
      for (; lastYieldedUpdateIndex < updates.count; lastYieldedUpdateIndex++) {
        var updateToYield = updates[lastYieldedUpdateIndex];
        yield updateToYield;
        if (activity != null) {
          Activity.current = activity;
        }
      }
      if (iteration >= maximumIterationsPerRequest ||
                hasApprovalRequiringFcc ||
                shouldTerminateLoopBasedOnHandleableFunctions(functionCallContents, options)) {
        break;
      }
      var response = updates.toChatResponse();
      (responseMessages ??= []).addRange(response.messages);
      // Prepare the history for the next iteration.
            fixupHistories(
              originalMessages,
              ref messages,
              ref augmentedHistory,
              response,
              responseMessages,
              ref lastIterationHadConversationId,
            );
      var modeAndMessages = await processFunctionCallsAsync(
        augmentedHistory,
        options,
        functionCallContents!,
        iteration,
        consecutiveErrorCount,
        isStreaming: true,
        cancellationToken,
      );
      responseMessages.addRange(modeAndMessages.messagesAdded);
      consecutiveErrorCount = modeAndMessages.newConsecutiveErrorCount;
      for (final message in modeAndMessages.messagesAdded) {
        yield convertToolResultMessageToUpdate(message, response.conversationId, toolMessageId);
        if (activity != null) {
          Activity.current = activity;
        }
      }
      if (modeAndMessages.shouldTerminate) {
        break;
      }
      updateOptionsForNextIteration(ref options, response.conversationId);
    }
    addUsageTags(activity, totalUsage);
  }

  static ChatResponseUpdate convertToolResultMessageToUpdate(
    ChatMessage message,
    String? conversationId,
    String? messageId,
  ) {
    return new()
        {
            AdditionalProperties = message.additionalProperties,
            AuthorName = message.authorName,
            ConversationId = conversationId,
            CreatedAt = DateTimeOffset.utcNow,
            Contents = message.contents,
            RawRepresentation = message.rawRepresentation,
            ResponseId = messageId,
            MessageId = messageId,
            Role = message.role,
        };
  }

  /// Adds tags to `activity` for usage details in `usage`.
  static void addUsageTags(Activity? activity, UsageDetails? usage, ) {
    if (usage != null && activity is { IsAllDataRequested: true }) {
      if (usage.inputTokenCount is long) {
        final inputTokens = usage.inputTokenCount as long;
        _ = activity.addTag(OpenTelemetryConsts.genAI.usage.inputTokens, (int)inputTokens);
      }
      if (usage.outputTokenCount is long) {
        final outputTokens = usage.outputTokenCount as long;
        _ = activity.addTag(OpenTelemetryConsts.genAI.usage.outputTokens, (int)outputTokens);
      }
    }
  }

  /// Prepares the various chat message lists after a response from the inner
  /// client and before invoking functions.
  ///
  /// [originalMessages] The original messages provided by the caller.
  ///
  /// [messages] The messages reference passed to the inner client.
  ///
  /// [augmentedHistory] The augmented history containing all the messages to be
  /// sent.
  ///
  /// [response] The most recent response being handled.
  ///
  /// [allTurnsResponseMessages] A list of all response messages received up
  /// until this point.
  ///
  /// [lastIterationHadConversationId] Whether the previous iteration's response
  /// had a conversation ID.
  static void fixupHistories(
    Iterable<ChatMessage> originalMessages,
    Iterable<ChatMessage> messages,
    List<ChatMessage>? augmentedHistory,
    ChatResponse response,
    List<ChatMessage> allTurnsResponseMessages,
    bool lastIterationHadConversationId,
  ) {
    if (response.conversationId != null) {
      if (augmentedHistory != null) {
        augmentedHistory.clear();
      } else {
        augmentedHistory = [];
      }
      lastIterationHadConversationId = true;
    } else if (lastIterationHadConversationId) {
      // In the very rare case where the inner client returned a response with a conversation ID but then
            // returned a subsequent response without one, we want to reconstitute the full history. To do that,
            // we can populate the history with the original chat messages and then all of the response
            // messages up until this point, which includes the most recent ones.
            augmentedHistory ??= [];
      augmentedHistory.clear();
      augmentedHistory.addRange(originalMessages);
      augmentedHistory.addRange(allTurnsResponseMessages);
      lastIterationHadConversationId = false;
    } else {
      // If augmentedHistory is already non-null, then we've already populated it with everything up
            // until this point (except for the most recent response). If it's null, we need to seed it with
            // the chat history provided by the caller.
            augmentedHistory ??= originalMessages.toList();
      // Now add the most recent response messages.
            augmentedHistory.addMessages(response);
      lastIterationHadConversationId = false;
    }
    // Use the augmented history as the new set of messages to send.
        messages = augmentedHistory;
  }

  /// Determines whether any of the tools in the specified lists require
  /// approval.
  ///
  /// Returns: `true` if any tool requires approval; otherwise, `false`.
  ///
  /// [toolLists] The lists of tools to check.
  static bool anyToolsRequireApproval(ReadOnlySpan<List<ATool>?> toolLists) {
    for (final toolList in toolLists) {
      if (toolList?.count is int count && count > 0) {
        for (var i = 0; i < count; i++) {
          if (toolList[i].getService<ApprovalRequiredAFunction>() != null) {
            return true;
          }
        }
      }
    }
    return false;
  }

  /// Finds a tool by name in the specified tool lists.
  ///
  /// Returns: The tool if found; otherwise, `null`.
  ///
  /// [name] The name of the tool to find.
  ///
  /// [toolLists] The lists of tools to search. Tools from earlier lists take
  /// precedence over tools from later lists if they have the same name.
  static AFunctionDeclaration? findTool(String name, ReadOnlySpan<List<ATool>?> toolLists, ) {
    for (final toolList in toolLists) {
      if (toolList != null) {
        for (final tool in toolList) {
          if (tool is AIFunctionDeclaration declaration && string.equals(tool.name, name, StringComparison.ordinal)) {
            return declaration;
          }
        }
      }
    }
    return null;
  }

  /// Checks whether there are any tools in the specified tool lists.
  ///
  /// Returns: `true` if there are any tools; otherwise, `false`.
  ///
  /// [toolLists] The lists of tools to check.
  static bool hasAnyTools(ReadOnlySpan<List<ATool>?> toolLists) {
    for (final toolList in toolLists) {
      if (toolList?.count > 0) {
        return true;
      }
    }
    return false;
  }

  /// Gets whether `messages` contains any [ToolApprovalRequestContent] or
  /// [ToolApprovalResponseContent] instances with a [FunctionCallContent] tool
  /// call that the FICC needs to process.
  static bool hasAnyApprovalContent(List<ChatMessage> messages) {
    return messages.exists((m) => m.contents.any((c) =>
            c is ToolApprovalRequestContent { ToolCall: FunctionCallContent { InformationalOnly: false } }
            or ToolApprovalResponseContent { ToolCall: FunctionCallContent { InformationalOnly: false } }));
  }

  /// Copies any [FunctionCallContent] from `messages` to `functionCalls`.
  static bool copyFunctionCalls(
    List<FunctionCallContent>? functionCalls,
    {List<ChatMessage>? messages, List<AContent>? content, },
  ) {
    var any = false;
    var count = messages.count;
    for (var i = 0; i < count; i++) {
      any |= copyFunctionCalls(messages[i].contents, ref functionCalls);
    }
    return any;
  }

  /// Marks any [FunctionCallContent] in `messages` as [InformationalOnly] if
  /// there is a matching [FunctionResultContent] with the same [CallId] in the
  /// same set of messages, regardless of order. This handles cases where the
  /// server has already executed the function and returned both the call and
  /// result.
  static void markServerHandledFunctionCalls({List<ChatMessage>? messages, List<ChatResponseUpdate>? updates, List<FunctionCallContent>? functionCallContents, }) {
    var resultCallIds = null;
    var messageCount = messages.count;
    for (var i = 0; i < messageCount; i++) {
      var contents = messages[i].contents;
      var contentCount = contents.count;
      for (var j = 0; j < contentCount; j++) {
        if (contents[j] is FunctionResultContent) {
          final frc = contents[j] as FunctionResultContent;
          _ = (resultCallIds ??= []).add(frc.callId);
        }
      }
    }
    if (resultCallIds == null) {
      return;
    }
    for (var i = 0; i < messageCount; i++) {
      var contents = messages[i].contents;
      var contentCount = contents.count;
      for (var j = 0; j < contentCount; j++) {
        if (contents[j] is FunctionCallContent fcc && !fcc.informationalOnly && resultCallIds.contains(fcc.callId)) {
          fcc.informationalOnly = true;
        }
      }
    }
  }

  static void updateOptionsForNextIteration(ChatOptions? options, String? conversationId, ) {
    if (options == null) {
      if (conversationId != null) {
        options = new() { ConversationId = conversationId };
      }
    } else if (options.toolMode is RequiredChatToolMode) {
      // We have to reset the tool mode to be non-required after the first iteration,
            // as otherwise we'll be in an infinite loop.
            options = options.clone();
      options.toolMode = null;
      options.conversationId = conversationId;
    } else if (options.conversationId != conversationId) {
      // As with the other modes, ensure we've propagated the chat conversation ID to the options.
            // We only need to clone the options if we're actually mutating it.
            options = options.clone();
      options.conversationId = conversationId;
    } else if (options.continuationToken != null) {
      // Clone options before resetting the continuation token below.
            options = options.clone();
    }
    if (options?.continuationToken != null) {
      options.continuationToken = null;
    }
  }

  /// Prepares options for the last iteration by removing AIFunctionDeclaration
  /// tools.
  ///
  /// Remarks: On the last iteration, we won't be processing any function calls,
  /// so we should not include AIFunctionDeclaration tools in the request. This
  /// prevents the inner client from returning tool call requests that won't be
  /// handled.
  ///
  /// [options] The chat options to prepare.
  static void prepareOptionsForLastIteration(ChatOptions? options) {
    if (options?.tools is not { Count: > 0 }) {
      return;
    }
    var remainingTools = null;
    for (final tool in options.tools) {
      if (tool is! AFunctionDeclaration) {
        remainingTools ??= [];
        remainingTools.add(tool);
      }
    }
    var remainingCount = remainingTools?.count ?? 0;
    if (remainingCount < options.tools.count) {
      options = options.clone();
      options.tools = remainingTools;
      if (remainingCount == 0) {
        options.toolMode = null;
      }
    }
  }

  /// Gets whether the function calling loop should exit based on the function
  /// call requests.
  ///
  /// [functionCalls] The call requests.
  ///
  /// [options] The options used for the response being processed.
  bool shouldTerminateLoopBasedOnHandleableFunctions(
    List<FunctionCallContent>? functionCalls,
    ChatOptions? options,
  ) {
    if (functionCalls is not { Count: > 0 }) {
      return true;
    }
    if (!hasAnyTools(options?.tools, additionalTools)) {
      if (terminateOnUnknownCalls) {
        for (final fcc in functionCalls) {
          logFunctionNotFound(fcc.name);
        }
      }
      return terminateOnUnknownCalls;
    }
    for (final fcc in functionCalls) {
      var tool = findTool(fcc.name, options?.tools, additionalTools);
      if (tool != null) {
        if (tool is! AFunction) {
          // The tool was found but it's not invocable. Regardless of TerminateOnUnknownCallRequests,
                    // we need to break out of the loop so that callers can handle all the call requests.
                    logNonInvocableFunction(fcc.name);
          return true;
        }
      } else {
        if (terminateOnUnknownCalls) {
          logFunctionNotFound(fcc.name);
          return true;
        }
      }
    }
    return false;
  }

  /// Processes the function calls in the `functionCallContents` list.
  ///
  /// Returns: A value indicating how the caller should proceed.
  ///
  /// [messages] The current chat contents, inclusive of the function call
  /// contents being processed.
  ///
  /// [options] The options used for the response being processed.
  ///
  /// [functionCallContents] The function call contents representing the
  /// functions to be invoked.
  ///
  /// [iteration] The iteration number of how many roundtrips have been made to
  /// the inner client.
  ///
  /// [consecutiveErrorCount] The number of consecutive iterations, prior to
  /// this one, that were recorded as having function invocation errors.
  ///
  /// [isStreaming] Whether the function calls are being processed in a
  /// streaming context.
  ///
  /// [cancellationToken] The [CancellationToken] to monitor for cancellation
  /// requests.
  Future<boolShouldTerminate, intNewConsecutiveErrorCount, ListChatMessageMessagesAdded> processFunctionCalls(
    List<ChatMessage> messages,
    ChatOptions? options,
    List<FunctionCallContent> functionCallContents,
    int iteration,
    int consecutiveErrorCount,
    bool isStreaming,
    CancellationToken cancellationToken,
  ) async  {
    // We must add a response for every tool call, regardless of whether we successfully executed it or not.
        // If we successfully execute it, we'll add the result. If we don't, we'll add an error.

        Debug.assertValue(functionCallContents.count > 0, "Expected at least one function call.");
    var captureCurrentIterationExceptions = consecutiveErrorCount < maximumConsecutiveErrorsPerRequest;
    var results = await processor.processFunctionCallsAsync(
            functionCallContents,
            (name) => findTool(name, options?.tools, additionalTools),
            allowConcurrentInvocation,
            (callContent, aiFunction, callIndex) => functionInvocationContext(),
                Messages = messages,
                Options = options,
                CallContent = callContent,
                Iteration = iteration,
                FunctionCallIndex = callIndex,
                FunctionCount = functionCallContents.count,
                IsStreaming = isStreaming
            },
            (ctx) => currentContext = ctx,
            captureCurrentIterationExceptions,
            cancellationToken).configureAwait(false);
  for (final result in results) {
    result.callContent.informationalOnly = true;
  }

  var shouldTerminate = results.exists((r) => r.terminate);
  var addedMessages = createResponseMessages(results.toArray());
  throwIfNoFunctionResultsAdded(addedMessages);
  updateConsecutiveErrorCountOrThrow(addedMessages, ref consecutiveErrorCount);
  messages.addRange(addedMessages);
  return (shouldTerminate, consecutiveErrorCount, addedMessages);
}
/// Updates the consecutive error count, and throws an exception if the count
/// exceeds the maximum.
///
/// [added] Added messages.
///
/// [consecutiveErrorCount] Consecutive error count.
void updateConsecutiveErrorCountOrThrow(List<ChatMessage> added, int consecutiveErrorCount, ) {
if (added.any((m) => m.contents.any((c) => c is FunctionResultContent { Exception: not null }))) {
  consecutiveErrorCount++;
  if (consecutiveErrorCount > maximumConsecutiveErrorsPerRequest) {
    logMaxConsecutiveErrorsExceeded(maximumConsecutiveErrorsPerRequest);
    var allExceptionsArray = added
                    .selectMany((m) => m.contents.ofType<FunctionResultContent>())
                    .select((frc) => frc.exception!)
                    .where((e) => e != null)
                    .toArray();
    if (allExceptionsArray.length == 1) {
      ExceptionDispatchInfo.capture(allExceptionsArray[0]).throwValue();
    }
    throw aggregateException(allExceptionsArray);
  }

} else {
  consecutiveErrorCount = 0;
}
 }
/// Throws an exception if [FunctionInvocationResult})] doesn't create any
/// messages.
void throwIfNoFunctionResultsAdded(List<ChatMessage>? messages) {
if (messages is not { Count: > 0 }) {
  Throw.invalidOperationException('${getType().name}.${nameof(CreateResponseMessages)} returned null or an empty collection of messages.');
}
 }
/// Creates one or more response messages for function invocation results.
///
/// Returns: A list of all chat messages created from `results`.
///
/// [results] Information about the function call invocations and results.
List<ChatMessage> createResponseMessages(ReadOnlySpan<FunctionInvocationResult> results) {
var contents = List<AContent>(results.length);
for (var i = 0; i < results.length; i++) {
  contents.add(createFunctionResultContent(results[i]));
}
return [new(ChatRole.tool, contents)];
/* TODO: unsupported node kind "unknown" */
// FunctionResultContent CreateFunctionResultContent(FunctionInvocationResult result)
//         {
//             _ = Throw.IfNull(result);
//
//             object? functionResult;
//             if (result.Status == FunctionInvocationStatus.RanToCompletion)
//             {
//                 // If the result is already a FunctionResultContent with a matching CallId, use it directly.
//                 if (result.Result is FunctionResultContent frc &&
//                     frc.CallId == result.CallContent.CallId)
//                 {
//                     return frc;
//                 }
//
//                 functionResult = result.Result ?? "Success: Function completed.";
//             }
//             else
//             {
//                 string message = result.Status switch
//                 {
//                     FunctionInvocationStatus.NotFound => $"Error: Requested function \"{result.CallContent.Name}\" not found.",
//                     FunctionInvocationStatus.Exception => "Error: Function failed.",
//                     _ => "Error: Unknown error.",
//                 };
//
//                 if (IncludeDetailedErrors && result.Exception is not null)
//                 {
//                     message = $"{message} Exception: {result.Exception.Message}";
//                 }
//
//                 functionResult = message;
//             }
//
//             return new FunctionResultContent(result.CallContent.CallId, functionResult) { Exception = result.Exception };
//         }
 }
/// This method will invoke the function within the try block.
///
/// Returns: The function result.
///
/// [context] The function invocation context.
///
/// [cancellationToken] Cancellation token.
Future<Object?> invokeFunction(
  FunctionInvocationContext context,
  CancellationToken cancellationToken,
) {
_ = Throw.ifNull(context);
return functionInvoker is { } invoker ?
            invoker(context, cancellationToken) :
            context.function.invokeAsync(context.arguments, cancellationToken);
 }
/// 1. Remove all [ToolApprovalRequestContent] and
/// [ToolApprovalResponseContent] from the `originalMessages`. 2. Recreate
/// [FunctionCallContent] for any [ToolApprovalResponseContent] that haven't
/// been executed yet. 3. Generate failed [FunctionResultContent] for any
/// rejected [ToolApprovalResponseContent]. 4. add all the new content items
/// to `originalMessages` and return them as the pre-invocation history.
ListChatMessagepreDownstreamCallHistoryListApprovalResultWithRequestMessageapprovals processFunctionApprovalResponses(
  List<ChatMessage> originalMessages,
  bool hasConversationId,
  String? toolMessageId,
  String? functionCallContentFallbackMessageId,
) {
var notInvokedResponses = extractAndRemoveApprovalRequestsAndResponses(originalMessages);
var allPreDownstreamCallMessages = convertToFunctionCallContentMessages(
            [.. notInvokedResponses.rejections ?? Enumerable.empty<ApprovalResultWithRequestMessage>(), .. notInvokedResponses.approvals ?? Enumerable.empty<ApprovalResultWithRequestMessage>()],
            functionCallContentFallbackMessageId);
var rejectedFunctionCallResults = generateRejectedFunctionResults(notInvokedResponses.rejections);
var rejectedPreDownstreamCallResultsMessage = rejectedFunctionCallResults != null ?
            chatMessage(ChatRole.tool, rejectedFunctionCallResults) :
            null;
var preDownstreamCallHistory = null;
if (allPreDownstreamCallMessages != null) {
  preDownstreamCallHistory = [.. allPreDownstreamCallMessages];
  if (!hasConversationId) {
    originalMessages.addRange(preDownstreamCallHistory);
  }
}
if (rejectedPreDownstreamCallResultsMessage != null) {
  (preDownstreamCallHistory ??= []).add(rejectedPreDownstreamCallResultsMessage);
  originalMessages.add(rejectedPreDownstreamCallResultsMessage);
}
return (preDownstreamCallHistory, notInvokedResponses.approvals);
 }
/// This method extracts the approval requests and responses from the provided
/// list of messages, validates them, filters them to ones that require
/// execution, and splits them into approved and rejected.
///
/// Remarks: We return the messages containing the approval requests since
/// these are the same messages that originally contained the
/// FunctionCallContent from the downstream service. We can then use the
/// metadata from these messages when we re-create the FunctionCallContent
/// messages/updates to return to the caller. This way, when we finally do
/// return the FunctionCallContent to users it's part of a message/update that
/// contains the same metadata as originally returned to the downstream
/// service.
ListApprovalResultWithRequestMessageapprovalsListApprovalResultWithRequestMessagerejections extractAndRemoveApprovalRequestsAndResponses(List<ChatMessage> messages) {
var allApprovalRequestsMessages = null;
var allApprovalResponses = null;
var approvalRequestCallIds = null;
var functionResultCallIds = null;
var anyRemoved = false;
var i = 0;
for (; i < messages.count; i++) {
  var message = messages[i];
  var keptContents = null;
  for (var j = 0; j < message.contents.count; j++) {
    var content = message.contents[j];
    switch (content) {
      case ToolApprovalRequestContent tarc:
        // Validation: Capture each call id for each approval request to ensure later we have a matching response.
                        _ = (approvalRequestCallIds ??= []).add(tarc.toolCall.callId);
        (allApprovalRequestsMessages ??= []).add(tarc.requestId, (message, tarc));
      case ToolApprovalResponseContent tarc:
        // Validation: Remove the call id for each approval response, to check it off the list of requests we need responses for.
                        _ = approvalRequestCallIds?.remove(tarc.toolCall.callId);
        (allApprovalResponses ??= []).add(tarc);
      case ToolApprovalResponseContent tarc:
        // Remove from validation set to handle sessions serialized before the fix
                        // for https://github.com/dotnet/extensions/pull/7468.
                        _ = approvalRequestCallIds?.remove(tarc.toolCall.callId);
        /* TODO: unsupported node kind "unknown" */
// goto default;
      case FunctionResultContent frc:
        // Maintain a list of function calls that have already been invoked to avoid invoking them twice.
                        _ = (functionResultCallIds ??= []).add(frc.callId);
        /* TODO: unsupported node kind "unknown" */
// goto default;
      default:
        // Content to keep.
                        (keptContents ??= []).add(content);
    }
  }

  if (keptContents?.count != message.contents.count) {
    if (keptContents is { Count: > 0 }) {
      var newMessage = message.clone();
      newMessage.contents = keptContents;
      messages[i] = newMessage;
    } else {
      // Remove the message entirely since it has no contents left. Rather than doing an o(N) removal, which could possibly
                    // result in an o(N^2) overall operation, we mark the message as null and then do a single pass removal of all nulls after the loop.
                    anyRemoved = true;
      messages[i] = null!;
    }
  }
}
if (anyRemoved) {
  _ = messages.removeAll((m) => m == null);
}
if (approvalRequestCallIds is { Count: > 0 }) {
  Throw.invalidOperationException(
                'ToolApprovalRequestContent found with FunctionCall.callId(s) '${string.join(", ", approvalRequestCallIds)}' that have no matching ToolApprovalResponseContent.');
}
var approvedFunctionCalls = null;
if (allApprovalResponses is { Count: > 0 }) {
  for (final approvalResponse in allApprovalResponses) {
    if (approvalResponse.toolCall is! FunctionCallContent fcc || functionResultCallIds?.contains(fcc.callId) is true) {
      continue;
    }
    logProcessingApprovalResponse(fcc.name, approvalResponse.approved);
    var targetList = ref approvalResponse.approved ? ref approvedFunctionCalls : ref rejectedFunctionCalls;
    var requestMessage = null;
    var requestContent = null;
    var requestInfo;
    if (allApprovalRequestsMessages?.tryGetValue(approvalResponse.requestId) is true) {
      requestMessage = requestInfo.message;
      requestContent = requestInfo.requestContent;
    }
    (targetList ??= []).add(new() { Response = approvalResponse, Request = requestContent, RequestMessage = requestMessage });
  }
}
return (approvedFunctionCalls, rejectedFunctionCalls);
 }
/// If we have any rejected approval responses, we need to generate failed
/// function results for them.
///
/// Returns: The [AIContent] for the rejected function calls.
///
/// [rejections] Any rejected approval responses.
List<AContent>? generateRejectedFunctionResults(List<ApprovalResultWithRequestMessage>? rejections) {
return rejections is { Count: > 0 } ?
            rejections.convertAll((m) =>
            {
                logFunctionRejected(m.responseFunctionCallContent.name, m.response.reason);

                string result = "Tool call invocation rejected.";
                if (!string.isNullOrWhiteSpace(m.response.reason))
                {
                    result = '${result} ${m.response.reason}';
                }

                // Mark the function call as purely informational since we're handling it (by rejecting it).
                // We mark both the response and request FunctionCallContent to ensure consistency
                // across serialization boundaries where they may be separate object instances.
                m.responseFunctionCallContent.informationalOnly = true;
                _ = m.requestFunctionCallContent?.informationalOnly = true;

                return (AIContent)functionResultContent(m.responseFunctionCallContent.callId, result);
            }) :
            null;
 }
/// Extracts the [FunctionCallContent] from the provided
/// [ToolApprovalResponseContent] to recreate the original function call
/// messages. The output messages tries to mimic the original messages that
/// contained the [FunctionCallContent], e.g. if the [FunctionCallContent] had
/// been split into separate messages, this method will recreate similarly
/// split messages, each with their own [FunctionCallContent].
static List<ChatMessage>? convertToFunctionCallContentMessages(
  List<ApprovalResultWithRequestMessage>? resultWithRequestMessages,
  String? fallbackMessageId,
) {
if (resultWithRequestMessages != null) {
  var currentMessage = null;
  var messagesById = null;
  for (final resultWithRequestMessage in resultWithRequestMessages) {
    if (messagesById == null && currentMessage != null

                    // Everywhere we have no RequestMessage we use the fallbackMessageId, so in this case there is only one message.
                    && !(resultWithRequestMessage.requestMessage == null && currentMessage.messageId == fallbackMessageId)

                    // Where we do have a RequestMessage, we can check if its message id differs from the current one.
                    && (resultWithRequestMessage.requestMessage != null && currentMessage.messageId != resultWithRequestMessage.requestMessage.messageId)) {
      // The majority of the time, all FCC would be part of a single message, so no need to create a dictionary for this case.
                    // If we are dealing with multiple messages though, we need to keep track of them by their message ID.
                    messagesById = [];
      var previousMessageKey = currentMessage.messageId == fallbackMessageId
                        ? string.empty
                        : (currentMessage.messageId ?? string.empty);
      messagesById[previousMessageKey] = currentMessage;
    }
    var messageKey = resultWithRequestMessage.requestMessage?.messageId ?? string.empty;
    _ = messagesById?.tryGetValue(messageKey, out currentMessage);
    if (currentMessage == null) {
      currentMessage = convertToFunctionCallContentMessage(
        resultWithRequestMessage,
        fallbackMessageId,
      );
    } else {
      currentMessage.contents.add(resultWithRequestMessage.response.toolCall);
    }
    #pragma warning disable IDE0058 // Temporary workaround for Roslyn analyzer issue (see https://github.com/dotnet/roslyn/issues/80499)
                messagesById?[messageKey] = currentMessage;
  }

  if (messagesById?.values is CollectionChatMessage) {
      final cm = messagesById?.values as CollectionChatMessage;
      return cm;
    }
  if (currentMessage != null) {
    return [currentMessage];
  }
}
return null;
 }
/// Takes the [FunctionCallContent] from the `resultWithRequestMessage` and
/// wraps it in a [ChatMessage] using the same message id that the
/// [FunctionCallContent] was originally returned with from the downstream
/// [ChatClient].
static ChatMessage convertToFunctionCallContentMessage(
  ApprovalResultWithRequestMessage resultWithRequestMessage,
  String? fallbackMessageId,
) {
var functionCallMessage = resultWithRequestMessage.requestMessage?.clone() ?? new() { Role = ChatRole.assistant };
functionCallMessage.contents = [resultWithRequestMessage.response.toolCall];
functionCallMessage.messageId ??= fallbackMessageId;
return functionCallMessage;
 }
/// Check if any of the provided `functionCallContents` require approval.
/// Supports checking from a provided index up to the end of the list, to
/// allow efficient incremental checking when streaming.
static boolhasApprovalRequiringFccintlastApprovalCheckedFCCIndex checkForApprovalRequiringFCC(
  List<FunctionCallContent>? functionCallContents,
  List<ATool> approvalRequiredFunctions,
  bool hasApprovalRequiringFcc,
  int lastApprovalCheckedFCCIndex,
) {
if (hasApprovalRequiringFcc) {
  Debug.assertValue(
    functionCallContents != null,
    "functionCallContents must not be null here,
    since we have already encountered approval requiring functionCallContents",
  );
  return (true, functionCallContents!.count);
}
if (functionCallContents != null) {
  for (; lastApprovalCheckedFCCIndex < functionCallContents.count; lastApprovalCheckedFCCIndex++) {
    var fcc = functionCallContents![lastApprovalCheckedFCCIndex];
    for (final arf in approvalRequiredFunctions) {
      if (arf.name == fcc.name) {
        hasApprovalRequiringFcc = true;
        break;
      }
    }
  }
}
return (hasApprovalRequiringFcc, lastApprovalCheckedFCCIndex);
 }
/// Replaces all [FunctionCallContent] with [ToolApprovalRequestContent] and
/// ouputs a new list if any of them were replaced.
///
/// Returns: true if any [FunctionCallContent] was replaced, false otherwise.
static (
  bool,
  List<AContent>??,
) tryReplaceFunctionCallsWithApprovalRequests(List<AContent> content) {
var updatedContent = null;
updatedContent = null;
if (content is { Count: > 0 }) {
  for (var i = 0; i < content.count; i++) {
      if (content[i] is FunctionCallContent fcc && !fcc.informationalOnly) {
            updatedContent ??= [.. content];
            updatedContent[i] = toolApprovalRequestContent(
              composeApprovalRequestId(fcc.callId),
              fcc,
            );
          }
    }
}
return (updatedContent != null, updatedContent);
 }
/// Replaces all [FunctionCallContent] from `messages` with
/// [ToolApprovalRequestContent] if any one of them requires approval.
List<ChatMessage> replaceFunctionCallsWithApprovalRequests(
  List<ChatMessage> messages,
  ReadOnlySpan<List<ATool>?> toolLists,
) {
var outputMessages = messages;
var anyApprovalRequired = false;
var allFunctionCallContentIndices = null;
for (var i = 0; i < messages.count; i++) {
  var content = messages[i].contents;
  for (var j = 0; j < content.count; j++) {
    if (content[j] is FunctionCallContent functionCall && !functionCall.informationalOnly) {
      (allFunctionCallContentIndices ??= []).add((i, j));
      anyApprovalRequired |= findTool(
        functionCall.name,
        toolLists,
      ) ?.getService<ApprovalRequiredAFunction>() != null;
    }
  }
}
if (anyApprovalRequired) {
  Debug.assertValue(
    allFunctionCallContentIndices != null,
    "We have already encountered function call contents that require approval.",
  );
  // Clone the list so, we don't mutate the input.
            outputMessages = [.. messages];
  var lastMessageIndex = -1;
  /* TODO: unsupported node kind "unknown" */
// foreach (var (messageIndex, contentIndex) in allFunctionCallContentIndices!)
//             {
//                 // Clone the message if we didn't already clone it in a previous iteration.
//                 var message = lastMessageIndex != messageIndex ? outputMessages[messageIndex].Clone() : outputMessages[messageIndex];
//                 message.Contents = [.. message.Contents];
//
//                 var functionCall = (FunctionCallContent)message.Contents[contentIndex];
//                 LogFunctionRequiresApproval(functionCall.Name);
//                 message.Contents[contentIndex] = new ToolApprovalRequestContent(ComposeApprovalRequestId(functionCall.CallId), functionCall);
//                 outputMessages[messageIndex] = message;
//
//                 lastMessageIndex = messageIndex;
//             }
}
return outputMessages;
 }
/// Composes an approval request ID from a function call ID.
static String composeApprovalRequestId(String callId) {
return 'ficc_${callId}';
 }
/// Execute the provided [ToolApprovalResponseContent] and return the
/// resulting [FunctionCallContent] wrapped in [ChatMessage] objects.
Future<ListChatMessageFunctionResultContentMessages, boolShouldTerminate, intConsecutiveErrorCount> invokeApprovedFunctionApprovalResponses(
  List<ApprovalResultWithRequestMessage>? notInvokedApprovals,
  List<ChatMessage> originalMessages,
  ChatOptions? options,
  int consecutiveErrorCount,
  bool isStreaming,
  CancellationToken cancellationToken,
) async  {
if (notInvokedApprovals is { Count: > 0 }) {
  var modeAndMessages = await processFunctionCallsAsync(
                originalMessages, options, notInvokedApprovals.select((x) => x.response.toolCall).ofType<FunctionCallContent>().toList(), 0, consecutiveErrorCount, isStreaming, cancellationToken);
  consecutiveErrorCount = modeAndMessages.newConsecutiveErrorCount;
  for (final approval in notInvokedApprovals) {
    _ = approval.requestFunctionCallContent?.informationalOnly = true;
  }

  return (modeAndMessages.messagesAdded, modeAndMessages.shouldTerminate, consecutiveErrorCount);
}
return (null, false, consecutiveErrorCount);
 }
void logMaximumIterationsReached(int maximumIterationsPerRequest) {
FunctionInvocationLogger.logMaximumIterationsReached(_logger, maximumIterationsPerRequest);
 }
void logFunctionRequiresApproval(String functionName) {
FunctionInvocationLogger.logFunctionRequiresApproval(_logger, functionName);
 }
void logProcessingApprovalResponse(String functionName, bool approved, ) {
FunctionInvocationLogger.logProcessingApprovalResponse(_logger, functionName, approved);
 }
void logFunctionRejected(String functionName, String? reason, ) {
FunctionInvocationLogger.logFunctionRejected(_logger, functionName, reason);
 }
void logMaxConsecutiveErrorsExceeded(int maxErrors) {
FunctionInvocationLogger.logMaxConsecutiveErrorsExceeded(_logger, maxErrors);
 }
void logFunctionNotFound(String functionName) {
FunctionInvocationLogger.logFunctionNotFound(_logger, functionName);
 }
void logNonInvocableFunction(String functionName) {
FunctionInvocationLogger.logNonInvocableFunction(_logger, functionName);
 }
 }
class ApprovalResultWithRequestMessage {
  ApprovalResultWithRequestMessage();

  ToolApprovalResponseContent response;

  ToolApprovalRequestContent? request;

  ChatMessage? requestMessage;

  FunctionCallContent get responseFunctionCallContent {
    return (FunctionCallContent)response.toolCall;
  }

  FunctionCallContent? get requestFunctionCallContent {
    return request?.toolCall as FunctionCallContent;
  }
}
/// Provides information about the invocation of a function call.
class FunctionInvocationResult {
  /// Initializes a new instance of the [FunctionInvocationResult] class.
  ///
  /// [terminate] Indicates whether the caller should terminate the processing
  /// loop.
  ///
  /// [status] Indicates the status of the function invocation.
  ///
  /// [callContent] Contains information about the function call.
  ///
  /// [result] The result of the function call.
  ///
  /// [exception] The exception thrown by the function call, if any.
  const FunctionInvocationResult(
    bool terminate,
    FunctionInvocationStatus status,
    FunctionCallContent callContent,
    Object? result,
    Exception? exception,
  ) :
      terminate = terminate,
      status = status,
      callContent = callContent,
      result = result,
      exception = exception;

  /// Gets status about how the function invocation completed.
  final FunctionInvocationStatus status;

  /// Gets the function call content information associated with this
  /// invocation.
  final FunctionCallContent callContent;

  /// Gets the result of the function call.
  final Object? result;

  /// Gets any exception the function call threw.
  final Exception? exception;

  /// Gets a value indicating whether the caller should terminate the processing
  /// loop.
  final bool terminate;

}
/// Provides error codes for when errors occur as part of the function calling
/// loop.
enum FunctionInvocationStatus { /// The operation completed successfully.
ranToCompletion,
/// The requested function could not be found.
notFound,
/// The function call failed with an exception.
exception }
