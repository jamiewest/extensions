import '../../../../../lib/func_typedefs.dart';
import '../abstractions/contents/function_call_content.dart';
import '../abstractions/contents/function_result_content.dart';
import '../abstractions/functions/ai_function.dart';
import '../abstractions/functions/ai_function_declaration.dart';
import '../abstractions/realtime/create_conversation_item_realtime_client_message.dart';
import '../abstractions/realtime/create_response_realtime_client_message.dart';
import '../abstractions/realtime/realtime_client_message.dart';
import '../abstractions/realtime/realtime_client_session.dart';
import '../abstractions/realtime/realtime_conversation_item.dart';
import '../abstractions/realtime/realtime_server_message.dart';
import '../abstractions/realtime/realtime_server_message_type.dart';
import '../abstractions/realtime/realtime_session_options.dart';
import '../abstractions/realtime/response_output_item_realtime_server_message.dart';
import '../abstractions/tools/ai_tool.dart';
import '../chat_completion/function_invocation_context.dart';
import '../chat_completion/function_invoking_chat_client.dart';
import '../common/function_invocation_helpers.dart';
import '../common/function_invocation_logger.dart';
import '../common/function_invocation_processor.dart';
import '../open_telemetry_consts.dart';
import 'function_invoking_realtime_client.dart';

/// A delegating realtime session that invokes functions defined on
/// [CreateResponseRealtimeClientMessage]. Include this in a realtime session
/// pipeline to resolve function calls automatically.
///
/// Remarks: When this session receives a [FunctionCallContent] in a realtime
/// server message from its inner [RealtimeClientSession], it responds by
/// invoking the corresponding [AIFunction] defined in [Tools] (or in
/// [AdditionalTools]), producing a [FunctionResultContent] that it sends back
/// to the inner session. This loop is repeated until there are no more
/// function calls to make, or until another stop condition is met, such as
/// hitting [MaximumIterationsPerRequest]. If a requested function is an
/// [AIFunctionDeclaration] but not an [AIFunction], the
/// [FunctionInvokingRealtimeClientSession] will not attempt to invoke it, and
/// instead allow that [FunctionCallContent] to pass back out to the caller.
/// It is then that caller's responsibility to create the appropriate
/// [FunctionResultContent] for that call and send it back as part of a
/// subsequent request. A [FunctionInvokingRealtimeClientSession] instance is
/// thread-safe for concurrent use so long as the [AIFunction] instances
/// employed as part of the supplied [CreateResponseRealtimeClientMessage] are
/// also safe. The [AllowConcurrentInvocation] property can be used to control
/// whether multiple function invocation requests as part of the same request
/// are invocable concurrently, but even with that set to `false` (the
/// default), multiple concurrent requests to this same instance and using the
/// same tools could result in those tools being used concurrently (one per
/// request). Known limitation: Function invocation blocks the message
/// processing loop. While functions are being invoked, incoming server
/// messages (including user interruptions) are buffered and not processed
/// until the invocation completes.
class FunctionInvokingRealtimeClientSession implements RealtimeClientSession {
  /// Initializes a new instance of the [FunctionInvokingRealtimeClientSession]
  /// class.
  ///
  /// [innerSession] The underlying [RealtimeClientSession], or the next
  /// instance in a chain of sessions.
  ///
  /// [client] The owning [FunctionInvokingRealtimeClient] that holds
  /// configuration.
  ///
  /// [loggerFactory] An [LoggerFactory] to use for logging information about
  /// function invocation.
  ///
  /// [functionInvocationServices] An optional [ServiceProvider] to use for
  /// resolving services required by the [AIFunction] instances being invoked.
  FunctionInvokingRealtimeClientSession(
    RealtimeClientSession innerSession,
    FunctionInvokingRealtimeClient client,
    {LoggerFactory? loggerFactory = null, ServiceProvider? functionInvocationServices = null, },
  ) :
      _innerSession = Throw.ifNull(innerSession),
      _client = Throw.ifNull(client),
      _logger = (ILogger?)loggerFactory?.createLogger<FunctionInvokingRealtimeClientSession>() ?? NullLogger.instance,
      _activitySource = innerSession.getService<ActivitySource>(),
      functionInvocationServices = functionInvocationServices;

  /// The [FunctionInvocationContext] for the current function invocation.
  static final AsyncLocal<FunctionInvocationContext?> _currentContext;

  /// Gets the [ServiceProvider] specified when constructing the
  /// [FunctionInvokingRealtimeClientSession], if any.
  final ServiceProvider? functionInvocationServices;

  /// The logger to use for logging information about function invocation.
  final Logger _logger;

  /// The [ActivitySource] to use for telemetry.
  ///
  /// Remarks: This component does not own the instance and should not dispose
  /// it.
  final ActivitySource? _activitySource;

  /// The inner session to delegate to.
  final RealtimeClientSession _innerSession;

  /// The owning client that holds configuration.
  final FunctionInvokingRealtimeClient _client;

  /// Gets or sets the [FunctionInvocationContext] for the current function
  /// invocation.
  ///
  /// Remarks: This value flows across async calls.
  static FunctionInvocationContext? currentContext;

  /// Gets the function invocation processor, creating it lazily.
  FunctionInvocationProcessor get processor {
    return field ??= functionInvocationProcessor(
        _logger,
        _activitySource,
        InvokeFunctionAsync);
  }

  bool get includeDetailedErrors {
    return _client.includeDetailedErrors;
  }

  bool get allowConcurrentInvocation {
    return _client.allowConcurrentInvocation;
  }

  int get maximumIterationsPerRequest {
    return _client.maximumIterationsPerRequest;
  }

  int get maximumConsecutiveErrorsPerRequest {
    return _client.maximumConsecutiveErrorsPerRequest;
  }

  List<ATool>? get additionalTools {
    return _client.additionalTools;
  }

  bool get terminateOnUnknownCalls {
    return _client.terminateOnUnknownCalls;
  }

  Func2<FunctionInvocationContext, CancellationToken, Future<Object?>>? get functionInvoker {
    return _client.functionInvoker;
  }

  RealtimeSessionOptions? get options {
    return _innerSession.options;
  }

  @override
  Future send(RealtimeClientMessage message, {CancellationToken? cancellationToken, }) {
    return _innerSession.sendAsync(message, cancellationToken);
  }

  @override
  Object? getService(Type serviceType, {Object? serviceKey, }) {
    _ = Throw.ifNull(serviceType);
    return serviceKey == null && serviceType.isInstanceOfType(this) ? this :
            _innerSession.getService(serviceType, serviceKey);
  }

  @override
  Future dispose() async  {
    await _innerSession.disposeAsync().configureAwait(false);
  }

  @override
  Stream<RealtimeServerMessage> getStreamingResponse({CancellationToken? cancellationToken}) async  {
    var activity = FunctionInvocationHelpers.currentActivityIsInvokeAgent ? null : _activitySource?.startActivity(OpenTelemetryConsts.genAI.orchestrateToolsName);
    var functionCallContents = null;
    var consecutiveErrorCount = 0;
    var iterationCount = 0;
    for (final message in _innerSession.getStreamingResponseAsync(cancellationToken).configureAwait(false)) {
      var hasFunctionCalls = false;
      if (message is ResponseOutputItemRealtimeServerMessage responseOutputItemMessage && responseOutputItemMessage.type == RealtimeServerMessageType.responseOutputItemDone) {
        // Extract function calls from the message
                functionCallContents ??= [];
        hasFunctionCalls = extractFunctionCalls(responseOutputItemMessage, functionCallContents);
      }
      yield message;
      if (hasFunctionCalls) {
        if (iterationCount >= maximumIterationsPerRequest) {
          // Log and stop processing function calls
                    FunctionInvocationLogger.logMaximumIterationsReached(
                      _logger,
                      maximumIterationsPerRequest,
                    );
          continue;
        }
        if (shouldTerminateBasedOnFunctionCalls(functionCallContents!)) {
          return;
        }
        // Process function calls
                iterationCount++;
        var results = await invokeFunctionsAsync(
          functionCallContents!,
          consecutiveErrorCount,
          cancellationToken,
        ) .configureAwait(false);
        // Update consecutive error count
                consecutiveErrorCount = results.newConsecutiveErrorCount;
        if (results.shouldTerminate) {
          return;
        }
        for (final resultMessage in results.functionResults) {
          // inject back the function result messages to the inner session
                    await _innerSession.sendAsync(
                      resultMessage,
                      cancellationToken,
                    ) .configureAwait(false);
        }
      }
    }
  }

  /// Extracts function calls from a realtime server message.
  static bool extractFunctionCalls(
    ResponseOutputItemRealtimeServerMessage message,
    List<FunctionCallContent> functionCallContents,
  ) {
    if (message.item == null) {
      return false;
    }
    functionCallContents.clear();
    for (final content in message.item.contents) {
      if (content is FunctionCallContent) {
        final functionCallContent = content as FunctionCallContent;
        functionCallContents.add(functionCallContent);
      }
    }
    return functionCallContents.count > 0;
  }

  /// Finds a tool by name in the specified tool lists.
  static AFunctionDeclaration? findTool(String name, ReadOnlySpan<Iterable<ATool>?> toolLists, ) {
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
  static bool hasAnyTools(ReadOnlySpan<Iterable<ATool>?> toolLists) {
    for (final toolList in toolLists) {
      if (toolList != null) {
        var enumerator = toolList.getIterable();
        if (enumerator.moveNext()) {
          return true;
        }
      }
    }
    return false;
  }

  /// Gets whether the function calling loop should exit based on the function
  /// call requests.
  ///
  /// Remarks: This mirrors the logic in
  /// `FunctionInvokingChatClient.ShouldTerminateLoopBasedOnHandleableFunctions`.
  /// If a function call references a non-invocable tool (a declaration but not
  /// an [AIFunction]), the loop always terminates. If the function is
  /// completely unknown, the loop terminates only when
  /// [TerminateOnUnknownCalls] is `true`.
  bool shouldTerminateBasedOnFunctionCalls(List<FunctionCallContent> functionCallContents) {
    if (!hasAnyTools(additionalTools, _innerSession.options?.tools)) {
      if (terminateOnUnknownCalls) {
        for (final fcc in functionCallContents) {
          FunctionInvocationLogger.logFunctionNotFound(_logger, fcc.name);
        }
        return true;
      }
      return false;
    }
    for (final fcc in functionCallContents) {
      var tool = findTool(fcc.name, additionalTools, _innerSession.options?.tools);
      if (tool != null) {
        if (tool is! AFunction) {
          // The tool exists but is! invocable (e.g. AIFunctionDeclaration only).
                    // Always terminate so the caller can handle the call.
                    FunctionInvocationLogger.logNonInvocableFunction(_logger, fcc.name);
          return true;
        }
      } else if (terminateOnUnknownCalls) {
        // The tool is completely unknown. If configured, terminate.
                FunctionInvocationLogger.logFunctionNotFound(_logger, fcc.name);
        return true;
      }
    }
    return false;
  }

  /// Invokes the functions and returns results.
  Future<boolshouldTerminate, intnewConsecutiveErrorCount, ListRealtimeClientMessagefunctionResults> invokeFunctions(
    List<FunctionCallContent> functionCallContents,
    int consecutiveErrorCount,
    CancellationToken cancellationToken,
  ) async  {
    var captureCurrentIterationExceptions = consecutiveErrorCount < maximumConsecutiveErrorsPerRequest;
    var results = await processor.processFunctionCallsAsync(
            functionCallContents,
            (name) => findTool(name, additionalTools, _innerSession.options?.tools),
            allowConcurrentInvocation,
            (callContent, aiFunction, _) => functionInvocationContext(),
                CallContent = callContent
            },
            (ctx) => currentContext = ctx,
            captureCurrentIterationExceptions,
            cancellationToken).configureAwait(false);
  var shouldTerminate = results.exists((r) => r.terminate);
  var hasErrors = results.exists((r) => r.status == FunctionInvocationStatus.exception);
  var newConsecutiveErrorCount = hasErrors ? consecutiveErrorCount + 1 : 0;
  if (newConsecutiveErrorCount > maximumConsecutiveErrorsPerRequest) {
    var firstException = results.find((r) => r.exception != null)?.exception;
    if (firstException != null) {
      throw firstException;
    }
  }

  var functionResults = createFunctionResultMessages(results);
  return (shouldTerminate, newConsecutiveErrorCount, functionResults);
}
/// Creates function result messages from invocation results.
List<RealtimeClientMessage> createFunctionResultMessages(List<FunctionInvocationResult> results) {
var messages = List<RealtimeClientMessage>(results.count);
for (final result in results) {
  var resultValue = result.status switch
            {
                FunctionInvocationStatus.ranToCompletion => result.result,
                FunctionInvocationStatus.notFound => "Error: Function not found.",
                FunctionInvocationStatus.exception => includeDetailedErrors && result.exception != null
                    ? 'Error: ${result.exception.message}'
                    : "Error: Function invocation failed.",
                (_) => "Error: Unknown status."
            };
  var functionResultContent = functionResultContent(result.callContent.callId, resultValue);
  var contentItem = realtimeConversationItem([functionResultContent]);
  var message = createConversationItemRealtimeClientMessage(contentItem);
  messages.add(message);
}
// Add a response create message so the model responds to the function results.
        // Do not hardcode output modalities; let the session defaults apply so audio sessions
        // continue to work correctly.
        messages.add(createResponseRealtimeClientMessage());
return messages;
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
 }
