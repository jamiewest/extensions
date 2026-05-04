import '../../../../../lib/func_typedefs.dart';
import '../abstractions/contents/function_call_content.dart';
import '../abstractions/functions/ai_function.dart';
import '../abstractions/tools/ai_tool.dart';
import '../chat_completion/function_invocation_context.dart';
import '../chat_completion/function_invoking_chat_client.dart';
import '../open_telemetry_consts.dart';
import '../realtime/function_invoking_realtime_client_session.dart';
import '../telemetry_helpers.dart';
import 'function_invocation_helpers.dart';
import 'function_invocation_logger.dart';

/// A composition-based helper class for processing function invocations. Used
/// by both [FunctionInvokingChatClient] and
/// [FunctionInvokingRealtimeClientSession].
class FunctionInvocationProcessor {
  /// Initializes a new instance of the [FunctionInvocationProcessor] class.
  ///
  /// [logger] The logger to use for logging.
  ///
  /// [activitySource] The activity source for telemetry.
  ///
  /// [invokeFunction] The delegate to invoke a function.
  ///
  /// [isSensitiveDataEnabled] A delegate that determines whether sensitive data
  /// logging is enabled. Receives the invoke agent activity (or null if not in
  /// agent context). Returns true if sensitive data should be logged/tagged,
  /// false otherwise.
  FunctionInvocationProcessor(
    Logger logger,
    ActivitySource? activitySource,
    Func2<FunctionInvocationContext, CancellationToken, Future<Object?>> invokeFunction,
    {Func<Activity?, bool>? isSensitiveDataEnabled = null, },
  ) :
      _logger = logger,
      _activitySource = activitySource,
      _invokeFunction = invokeFunction,
      _isSensitiveDataEnabled = isSensitiveDataEnabled ?? ((_) => false);

  final Logger _logger;

  final ActivitySource? _activitySource;

  final Func2<FunctionInvocationContext, CancellationToken, Future<Object?>> _invokeFunction;

  final Func<Activity?, bool> _isSensitiveDataEnabled;

  /// Processes multiple function calls, either concurrently or serially.
  ///
  /// Returns: A list of function invocation results.
  ///
  /// [functionCallContents] The function calls to process.
  ///
  /// [findTool] Delegate to look up a tool by name. Returns null if not found.
  ///
  /// [allowConcurrentInvocation] Whether to allow concurrent invocation.
  ///
  /// [createContext] Delegate to create a [FunctionInvocationContext] for each
  /// function call.
  ///
  /// [setCurrentContext] Delegate to set the current context (for AsyncLocal
  /// flow).
  ///
  /// [captureExceptionsWhenSerial] Whether to capture exceptions when running
  /// serially (typically based on consecutive error count).
  ///
  /// [cancellationToken] Cancellation token.
  Future<List<FunctionInvocationResult>> processFunctionCalls(
    List<FunctionCallContent> functionCallContents,
    Func<String, ATool?> findTool,
    bool allowConcurrentInvocation,
    Func3<FunctionCallContent, AFunction, int, FunctionInvocationContext> createContext,
    Action<FunctionInvocationContext?> setCurrentContext,
    bool captureExceptionsWhenSerial,
    CancellationToken cancellationToken,
  ) async  {
    var results = List<FunctionInvocationResult>();
    if (allowConcurrentInvocation && functionCallContents.count > 1) {
      // Invoke functions concurrently - always capture exceptions in parallel mode
            results.addRange(await Task.whenAll(
                from callIndex in Enumerable.range(0, functionCallContents.count)
                select processSingleFunctionCallAsync(
                    functionCallContents[callIndex], findTool, callIndex,
                    createContext, setCurrentContext, captureExceptions: true, cancellationToken)).configureAwait(false));
    } else {
      for (var callIndex = 0; callIndex < functionCallContents.count; callIndex++) {
        var result = await processSingleFunctionCallAsync(
                    functionCallContents[callIndex], findTool, callIndex,
                    createContext, setCurrentContext, captureExceptionsWhenSerial, cancellationToken).configureAwait(false);
        results.add(result);
        if (result.terminate) {
          break;
        }
      }
    }
    return results;
  }

  /// Processes a single function call.
  Future<FunctionInvocationResult> processSingleFunctionCall(
    FunctionCallContent callContent,
    Func<String, ATool?> findTool,
    int callIndex,
    Func3<FunctionCallContent, AFunction, int, FunctionInvocationContext> createContext,
    Action<FunctionInvocationContext?> setCurrentContext,
    bool captureExceptions,
    CancellationToken cancellationToken,
  ) async  {
    var tool = findTool(callContent.name);
    if (tool == null) {
      FunctionInvocationLogger.logFunctionNotFound(_logger, callContent.name);
      return new(
        terminate: false,
        FunctionInvocationStatus.notFound,
        callContent,
        result: null,
        exception: null,
      );
    }
    if (tool is! AFunction aiFunction) {
      FunctionInvocationLogger.logNonInvocableFunction(_logger, callContent.name);
      return new(
        terminate: false,
        FunctionInvocationStatus.notFound,
        callContent,
        result: null,
        exception: null,
      );
    }
    var context = createContext(callContent, aiFunction, callIndex);
    try {
      setCurrentContext(context);
      var result = await instrumentedInvokeFunctionAsync(
        context,
        cancellationToken,
      ) .configureAwait(false);
      if (context.terminate) {
        FunctionInvocationLogger.logFunctionRequestedTermination(_logger, callContent.name);
      }
      return new(
        context.terminate,
        FunctionInvocationStatus.ranToCompletion,
        callContent,
        result,
        exception: null,
      );
    } catch (e, s) {
      if (e is Exception) {
        final ex = e as Exception;
        {
          return new(
            terminate: false,
            FunctionInvocationStatus.exception,
            callContent,
            result: null,
            exception: ex,
          );
        }
      } else {
        rethrow;
      }
    } finally {
      setCurrentContext(null);
    }
  }

  /// Invokes the function with instrumentation (logging and telemetry).
  Future<Object?> instrumentedInvokeFunction(
    FunctionInvocationContext context,
    CancellationToken cancellationToken,
  ) async  {
    var invokeAgentActivity = FunctionInvocationHelpers.currentActivityIsInvokeAgent ? Activity.current : null;
    var source = invokeAgentActivity?.source ?? _activitySource;
    var activity = source?.startActivity(
            '${OpenTelemetryConsts.genAI.executeToolName} ${context.function.name}',
            ActivityKind.internal,
            default(ActivityContext),
            [
                new(
                  OpenTelemetryConsts.genAI.operation.name,
                  OpenTelemetryConsts.genAI.executeToolName,
                ),
                new(OpenTelemetryConsts.genAI.tool.type, OpenTelemetryConsts.toolTypeFunction),
                new(OpenTelemetryConsts.genAI.tool.call.id, context.callContent.callId),
                new(OpenTelemetryConsts.genAI.tool.name, context.function.name),
                new(OpenTelemetryConsts.genAI.tool.description, context.function.description),
            ]);
    var startingTimestamp = Stopwatch.getTimestamp();
    var enableSensitiveData = activity is { IsAllDataRequested: true } && _isSensitiveDataEnabled(invokeAgentActivity);
    var traceLoggingEnabled = _logger.isEnabled(LogLevel.trace);
    var loggedInvoke = false;
    if (enableSensitiveData || traceLoggingEnabled) {
      var functionArguments = TelemetryHelpers.asJson(
        context.arguments,
        context.function.jsonSerializerOptions,
      );
      if (enableSensitiveData) {
        _ = activity?.setTag(OpenTelemetryConsts.genAI.tool.call.arguments, functionArguments);
      }
      if (traceLoggingEnabled) {
        FunctionInvocationLogger.logInvokingSensitive(
          _logger,
          context.function.name,
          functionArguments,
        );
        loggedInvoke = true;
      }
    }
    if (!loggedInvoke && _logger.isEnabled(LogLevel.debug)) {
      FunctionInvocationLogger.logInvoking(_logger, context.function.name);
    }
    var result = null;
    try {
      result = await _invokeFunction(context, cancellationToken).configureAwait(false);
    } catch (e, s) {
      if (e is Exception) {
        final e = e as Exception;
        {
          if (activity != null) {
            _ = activity.setTag(OpenTelemetryConsts.error.type, e.getType().fullName)
                            .setStatus(ActivityStatusCode.error, e.message);
          }
          if (e is OperationCanceledException) {
            FunctionInvocationLogger.logInvocationCanceled(_logger, context.function.name);
          } else {
            FunctionInvocationLogger.logInvocationFailed(_logger, context.function.name, e);
          }
          rethrow;
        }
      } else {
        rethrow;
      }
    } finally {
      var loggedResult = false;
      if (enableSensitiveData || traceLoggingEnabled) {
        var functionResult = TelemetryHelpers.asJson(
          result,
          context.function.jsonSerializerOptions,
        );
        if (enableSensitiveData) {
          _ = activity?.setTag(OpenTelemetryConsts.genAI.tool.call.result, functionResult);
        }
        if (traceLoggingEnabled) {
          FunctionInvocationLogger.logInvocationCompletedSensitive(
            _logger,
            context.function.name,
            FunctionInvocationHelpers.getElapsedTime(startingTimestamp),
            functionResult,
          );
          loggedResult = true;
        }
      }
      if (!loggedResult && _logger.isEnabled(LogLevel.debug)) {
        FunctionInvocationLogger.logInvocationCompleted(
          _logger,
          context.function.name,
          FunctionInvocationHelpers.getElapsedTime(startingTimestamp),
        );
      }
    }
    return result;
  }
}
