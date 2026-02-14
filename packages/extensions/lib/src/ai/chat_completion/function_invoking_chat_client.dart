import 'dart:async';

import '../../logging/logger.dart';
import '../../logging/logger_extensions.dart';
import '../../system/threading/cancellation_token.dart';
import '../ai_content.dart';
import '../function_call_content.dart';
import '../function_result_content.dart';
import '../functions/ai_function.dart';
import '../functions/ai_function_arguments.dart';
import '../tools/ai_tool.dart';
import 'chat_message.dart';
import 'chat_options.dart';
import 'chat_response.dart';
import 'chat_response_update.dart';
import 'chat_role.dart';
import 'delegating_chat_client.dart';

/// The status of a function invocation.
enum FunctionInvocationStatus {
  /// The function ran to completion.
  ranToCompletion,

  /// The function was not found.
  notFound,

  /// The function threw an exception.
  exception,
}

/// The result of a function invocation.
class FunctionInvocationResult {
  /// Creates a new [FunctionInvocationResult].
  FunctionInvocationResult({
    required this.status,
    required this.callContent,
    this.result,
    this.exception,
    this.terminate = false,
  });

  /// The status of the invocation.
  final FunctionInvocationStatus status;

  /// The original function call content.
  final FunctionCallContent callContent;

  /// The result of the function invocation.
  final Object? result;

  /// The exception that occurred, if any.
  final Object? exception;

  /// Whether to terminate the function invocation loop.
  bool terminate;
}

/// A delegating chat client that automatically invokes functions
/// requested by the model.
///
/// When the model responds with function call requests, this client
/// invokes the corresponding [AIFunction] tools and feeds the results
/// back to the model, repeating until the model produces a final
/// response or the maximum number of iterations is reached.
class FunctionInvokingChatClient extends DelegatingChatClient {
  /// Creates a new [FunctionInvokingChatClient].
  FunctionInvokingChatClient(
    super.innerClient, {
    this.logger,
  });

  /// An optional logger for diagnostic output.
  final Logger? logger;

  /// Whether to include detailed error information in function results
  /// sent to the model.
  ///
  /// Defaults to `false`. When `false`, a generic error message is sent
  /// instead of the actual exception details.
  bool includeDetailedErrors = false;

  /// Whether to allow concurrent invocation of multiple function calls.
  ///
  /// Defaults to `false`. When `true`, multiple function calls in a
  /// single response are invoked concurrently.
  bool allowConcurrentInvocation = false;

  /// The maximum number of roundtrips per request.
  ///
  /// Defaults to 10.
  int maximumIterationsPerRequest = 10;

  /// The maximum number of consecutive errors before stopping.
  ///
  /// Defaults to 3.
  int maximumConsecutiveErrorsPerRequest = 3;

  /// Additional tools available for function invocation beyond
  /// those specified in [ChatOptions.tools].
  List<AITool>? additionalTools;

  /// Whether to terminate when a function call references an unknown tool.
  ///
  /// Defaults to `false`.
  bool terminateOnUnknownCalls = false;

  @override
  Future<ChatResponse> getResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    final allTools = _getAllTools(options);
    if (allTools.isEmpty) {
      return super.getResponse(
        messages: messages,
        options: options,
        cancellationToken: cancellationToken,
      );
    }

    final messageList = messages.toList();
    var iterations = 0;
    var consecutiveErrors = 0;

    while (true) {
      final response = await super.getResponse(
        messages: messageList,
        options: options,
        cancellationToken: cancellationToken,
      );

      // Check for function calls in the response
      final lastMessage =
          response.messages.isNotEmpty ? response.messages.last : null;
      if (lastMessage == null) return response;

      final functionCalls =
          lastMessage.contents.whereType<FunctionCallContent>().toList();

      if (functionCalls.isEmpty) return response;

      iterations++;
      if (iterations > maximumIterationsPerRequest) return response;

      // Add the assistant message with function calls
      messageList.add(lastMessage);

      // Invoke the functions
      final results = await _invokeFunctions(
        functionCalls,
        allTools,
        cancellationToken,
      );

      // Check for errors
      final hasErrors =
          results.any((r) => r.status == FunctionInvocationStatus.exception);
      if (hasErrors) {
        consecutiveErrors++;
        if (consecutiveErrors >= maximumConsecutiveErrorsPerRequest) {
          return response;
        }
      } else {
        consecutiveErrors = 0;
      }

      // Check for termination
      if (results.any((r) => r.terminate)) return response;

      // Add tool results as a tool message
      final resultContents = results
          .map((r) => FunctionResultContent(
                callId: r.callContent.callId,
                result: r.result,
                exception:
                    r.exception is Exception ? r.exception as Exception : null,
              ))
          .toList();

      messageList.add(ChatMessage(
        role: ChatRole.tool,
        contents: resultContents.cast<AIContent>(),
      ));
    }
  }

  @override
  Stream<ChatResponseUpdate> getStreamingResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) {
    final allTools = _getAllTools(options);
    if (allTools.isEmpty) {
      return super.getStreamingResponse(
        messages: messages,
        options: options,
        cancellationToken: cancellationToken,
      );
    }

    Stream<ChatResponseUpdate> stream() async* {
      final messageList = messages.toList();
      var iterations = 0;
      var consecutiveErrors = 0;

      while (true) {
        // Collect the streaming response
        final updates = <ChatResponseUpdate>[];
        final functionCalls = <FunctionCallContent>[];

        await for (final update in super.getStreamingResponse(
          messages: messageList,
          options: options,
          cancellationToken: cancellationToken,
        )) {
          updates.add(update);
          functionCalls
              .addAll(update.contents.whereType<FunctionCallContent>());

          // Only yield non-function-call content
          if (update.contents.whereType<FunctionCallContent>().isEmpty) {
            yield update;
          }
        }

        if (functionCalls.isEmpty) return;

        iterations++;
        if (iterations > maximumIterationsPerRequest) return;

        // Build assistant message from updates
        final assistantContents = <AIContent>[];
        for (final update in updates) {
          for (final content in update.contents) {
            assistantContents.add(content);
          }
        }
        messageList.add(ChatMessage(
          role: ChatRole.assistant,
          contents: assistantContents,
        ));

        // Invoke functions
        final results = await _invokeFunctions(
          functionCalls,
          allTools,
          cancellationToken,
        );

        final hasErrors =
            results.any((r) => r.status == FunctionInvocationStatus.exception);
        if (hasErrors) {
          consecutiveErrors++;
          if (consecutiveErrors >= maximumConsecutiveErrorsPerRequest) return;
        } else {
          consecutiveErrors = 0;
        }

        if (results.any((r) => r.terminate)) return;

        final resultContents = results
            .map((r) => FunctionResultContent(
                  callId: r.callContent.callId,
                  result: r.result,
                  exception: r.exception is Exception
                      ? r.exception as Exception
                      : null,
                ))
            .toList();

        messageList.add(ChatMessage(
          role: ChatRole.tool,
          contents: resultContents.cast<AIContent>(),
        ));
      }
    }

    return stream();
  }

  List<AITool> _getAllTools(ChatOptions? options) {
    final tools = <AITool>[];
    if (options?.tools != null) tools.addAll(options!.tools!);
    if (additionalTools != null) tools.addAll(additionalTools!);
    return tools;
  }

  Future<List<FunctionInvocationResult>> _invokeFunctions(
    List<FunctionCallContent> calls,
    List<AITool> tools,
    CancellationToken? cancellationToken,
  ) async {
    if (allowConcurrentInvocation) {
      return Future.wait(
          calls.map((call) => _invokeFunction(call, tools, cancellationToken)));
    }

    final results = <FunctionInvocationResult>[];
    for (final call in calls) {
      results.add(await _invokeFunction(call, tools, cancellationToken));
    }
    return results;
  }

  Future<FunctionInvocationResult> _invokeFunction(
    FunctionCallContent call,
    List<AITool> tools,
    CancellationToken? cancellationToken,
  ) async {
    final tool = tools
        .whereType<AIFunction>()
        .where((t) => t.name == call.name)
        .firstOrNull;

    if (tool == null) {
      final errorMessage = 'Function "${call.name}" not found.';
      logger?.logError(errorMessage);

      if (terminateOnUnknownCalls) {
        return FunctionInvocationResult(
          status: FunctionInvocationStatus.notFound,
          callContent: call,
          result: errorMessage,
          terminate: true,
        );
      }

      return FunctionInvocationResult(
        status: FunctionInvocationStatus.notFound,
        callContent: call,
        result: errorMessage,
      );
    }

    try {
      final arguments = AIFunctionArguments(call.arguments);
      final result = await tool.invoke(
        arguments,
        cancellationToken: cancellationToken,
      );

      return FunctionInvocationResult(
        status: FunctionInvocationStatus.ranToCompletion,
        callContent: call,
        result: result,
      );
    } catch (e) {
      logger?.logError(
        'Function "${call.name}" threw an exception.',
        error: e,
      );

      final errorResult = includeDetailedErrors
          ? e.toString()
          : 'An error occurred invoking the function.';

      return FunctionInvocationResult(
        status: FunctionInvocationStatus.exception,
        callContent: call,
        result: errorResult,
        exception: e,
      );
    }
  }
}
