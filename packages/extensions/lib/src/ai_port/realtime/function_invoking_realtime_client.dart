import '../../../../../lib/func_typedefs.dart';
import '../abstractions/contents/function_call_content.dart';
import '../abstractions/contents/function_result_content.dart';
import '../abstractions/functions/ai_function.dart';
import '../abstractions/realtime/create_response_realtime_client_message.dart';
import '../abstractions/realtime/delegating_realtime_client.dart';
import '../abstractions/realtime/realtime_client.dart';
import '../abstractions/realtime/realtime_client_session.dart';
import '../abstractions/realtime/realtime_session_options.dart';
import '../abstractions/tools/ai_tool.dart';
import '../chat_completion/function_invocation_context.dart';
import 'function_invoking_realtime_client_session.dart';

/// A delegating realtime client that invokes functions defined on
/// [CreateResponseRealtimeClientMessage]. Include this in a realtime client
/// pipeline to resolve function calls automatically.
///
/// Remarks: When sessions created by this client receive a
/// [FunctionCallContent] in a realtime server message from the inner
/// [RealtimeClientSession], they respond by invoking the corresponding
/// [AIFunction] defined in [Tools] (or in [AdditionalTools]), producing a
/// [FunctionResultContent] that is sent back to the inner session. This loop
/// is repeated until there are no more function calls to make, or until
/// another stop condition is met, such as hitting
/// [MaximumIterationsPerRequest].
class FunctionInvokingRealtimeClient extends DelegatingRealtimeClient {
  /// Initializes a new instance of the [FunctionInvokingRealtimeClient] class.
  ///
  /// [innerClient] The inner [RealtimeClient].
  ///
  /// [loggerFactory] An [LoggerFactory] to use for logging information about
  /// function invocation.
  ///
  /// [functionInvocationServices] An optional [ServiceProvider] to use for
  /// resolving services required by the [AIFunction] instances being invoked.
  FunctionInvokingRealtimeClient(
    RealtimeClient innerClient, {
    LoggerFactory? loggerFactory = null,
    ServiceProvider? functionInvocationServices = null,
  }) : _loggerFactory = loggerFactory,
       _services = functionInvocationServices;

  final LoggerFactory? _loggerFactory;

  final ServiceProvider? _services;

  /// Gets or sets a value indicating whether detailed exception information
  /// should be included in the response when calling the underlying
  /// [RealtimeClientSession].
  bool includeDetailedErrors;

  /// Gets or sets a value indicating whether to allow concurrent invocation of
  /// functions.
  bool allowConcurrentInvocation;

  /// Gets or sets the maximum number of iterations per request.
  int maximumIterationsPerRequest = 40;

  /// Gets or sets the maximum number of consecutive iterations that are allowed
  /// to fail with an error.
  int maximumConsecutiveErrorsPerRequest = 3;

  /// Gets or sets a collection of additional tools the session is able to
  /// invoke.
  List<ATool>? additionalTools;

  /// Gets or sets a value indicating whether a request to call an unknown
  /// function should terminate the function calling loop.
  bool terminateOnUnknownCalls;

  /// Gets or sets a delegate used to invoke [AIFunction] instances.
  Func2<FunctionInvocationContext, CancellationToken, Future<Object?>>?
  functionInvoker;

  /// Gets the [FunctionInvocationContext] for the current function invocation.
  ///
  /// Remarks: This value flows across async calls.
  static FunctionInvocationContext? get currentContext {
    return FunctionInvokingRealtimeClientSession.currentContext;
  }

  @override
  Future<RealtimeClientSession> createSession({
    RealtimeSessionOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    var innerSession = await base
        .createSessionAsync(options, cancellationToken)
        .configureAwait(false);
    return functionInvokingRealtimeClientSession(
      innerSession,
      this,
      _loggerFactory,
      _services,
    );
  }
}
