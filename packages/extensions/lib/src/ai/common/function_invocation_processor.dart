import 'dart:developer' as developer;

import 'package:extensions/annotations.dart';

import '../../logging/log_level.dart';
import '../../logging/logger.dart';
import '../../system/exceptions/operation_cancelled_exception.dart';
import '../../system/threading/cancellation_token.dart';
import '../chat_completion/function_invoking_chat_client.dart'
    show FunctionInvocationResult, FunctionInvocationStatus;
import '../function_call_content.dart';
import '../functions/ai_function.dart';
import '../functions/ai_function_arguments.dart';
import '../open_telemetry_consts.dart';
import '../tools/ai_tool.dart';
import 'function_invocation_logger.dart';
import 'telemetry_helpers.dart';

/// Looks up the tool a function call refers to, or `null` when unknown.
typedef FunctionInvocationToolResolver = AITool? Function(String name);

/// A composition-based helper for processing function invocations,
/// shared between `FunctionInvokingChatClient` and
/// `FunctionInvokingRealtimeClientSession`.
///
/// Not exported from the `ai` barrel; this mirrors the C# `internal`
/// type. The upstream `ActivitySource` instrumentation is represented
/// with `dart:developer` timeline spans (`execute_tool`), consistent
/// with the spans-only OpenTelemetry decision for this port.
@Source(
  name: 'FunctionInvocationProcessor.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI/Common/',
)
final class FunctionInvocationProcessor {
  /// Creates a new [FunctionInvocationProcessor].
  FunctionInvocationProcessor({this.logger});

  /// The logger used for invocation diagnostics.
  final Logger? logger;

  /// Processes [callContents], either concurrently or serially.
  ///
  /// [findTool] resolves each call's tool by name. Unknown and
  /// declaration-only tools produce a
  /// [FunctionInvocationStatus.notFound] result whose `result` text
  /// explains the failure to the model; [terminateOnUnknownCalls] marks
  /// those results as terminating. Errors thrown by tools are captured
  /// as [FunctionInvocationStatus.exception] results — with the error
  /// text included when [includeDetailedErrors] is set — except
  /// cancellation, which propagates.
  ///
  /// In serial mode, processing stops after a result that requests
  /// termination.
  Future<List<FunctionInvocationResult>> processFunctionCalls(
    List<FunctionCallContent> callContents, {
    required FunctionInvocationToolResolver findTool,
    required bool allowConcurrentInvocation,
    bool includeDetailedErrors = false,
    bool terminateOnUnknownCalls = false,
    CancellationToken? cancellationToken,
  }) async {
    Future<FunctionInvocationResult> processSingle(
      FunctionCallContent call,
    ) =>
        _processSingleCall(
          call,
          findTool: findTool,
          includeDetailedErrors: includeDetailedErrors,
          terminateOnUnknownCalls: terminateOnUnknownCalls,
          cancellationToken: cancellationToken,
        );

    if (allowConcurrentInvocation && callContents.length > 1) {
      return Future.wait(callContents.map(processSingle));
    }

    final results = <FunctionInvocationResult>[];
    for (final call in callContents) {
      final result = await processSingle(call);
      results.add(result);
      if (result.terminate) {
        break;
      }
    }
    return results;
  }

  Future<FunctionInvocationResult> _processSingleCall(
    FunctionCallContent call, {
    required FunctionInvocationToolResolver findTool,
    required bool includeDetailedErrors,
    required bool terminateOnUnknownCalls,
    CancellationToken? cancellationToken,
  }) async {
    final tool = findTool(call.name);
    if (tool == null || tool is! AIFunction) {
      if (tool == null) {
        FunctionInvocationLogger.functionNotFound(logger, call.name);
      } else {
        FunctionInvocationLogger.nonInvocableFunction(logger, call.name);
      }

      return FunctionInvocationResult(
        status: FunctionInvocationStatus.notFound,
        callContent: call,
        result: 'Function "${call.name}" not found.',
        terminate: terminateOnUnknownCalls,
      );
    }

    try {
      final result = await _instrumentedInvoke(
        tool,
        call,
        cancellationToken,
      );
      return FunctionInvocationResult(
        status: FunctionInvocationStatus.ranToCompletion,
        callContent: call,
        result: result,
      );
    } catch (e) {
      if (cancellationToken?.isCancellationRequested ?? false) {
        rethrow;
      }

      return FunctionInvocationResult(
        status: FunctionInvocationStatus.exception,
        callContent: call,
        result: includeDetailedErrors
            ? e.toString()
            : 'An error occurred invoking the function.',
        exception: e,
      );
    }
  }

  Future<Object?> _instrumentedInvoke(
    AIFunction function,
    FunctionCallContent call,
    CancellationToken? cancellationToken,
  ) async {
    developer.Timeline.startSync(
      '${OpenTelemetryConsts.executeToolSpanName} ${function.name}',
      arguments: {
        OpenTelemetryConsts.operationNameKey:
            OpenTelemetryConsts.executeToolSpanName,
        OpenTelemetryConsts.toolTypeKey: OpenTelemetryConsts.toolTypeFunction,
        OpenTelemetryConsts.toolCallIdKey: call.callId,
        OpenTelemetryConsts.toolNameKey: function.name,
        if (function.description != null)
          OpenTelemetryConsts.toolDescriptionKey: function.description,
      },
    );

    final traceEnabled = logger?.isEnabled(LogLevel.trace) ?? false;
    if (traceEnabled) {
      FunctionInvocationLogger.invokingSensitive(
        logger,
        function.name,
        TelemetryHelpers.asJson(call.arguments),
      );
    } else {
      FunctionInvocationLogger.invoking(logger, function.name);
    }

    final stopwatch = Stopwatch()..start();
    Object? result;
    try {
      result = await function.invoke(
        AIFunctionArguments(call.arguments),
        cancellationToken: cancellationToken,
      );
    } catch (e) {
      if (e is OperationCanceledException) {
        FunctionInvocationLogger.invocationCanceled(logger, function.name);
      } else {
        FunctionInvocationLogger.invocationFailed(logger, function.name, e);
      }
      rethrow;
    } finally {
      stopwatch.stop();
      developer.Timeline.finishSync();
      if (traceEnabled) {
        FunctionInvocationLogger.invocationCompletedSensitive(
          logger,
          function.name,
          stopwatch.elapsed,
          TelemetryHelpers.asJson(result),
        );
      } else {
        FunctionInvocationLogger.invocationCompleted(
          logger,
          function.name,
          stopwatch.elapsed,
        );
      }
    }

    return result;
  }
}
