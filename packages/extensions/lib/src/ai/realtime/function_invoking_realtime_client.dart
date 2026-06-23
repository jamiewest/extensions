import 'package:extensions/annotations.dart';

import '../../logging/logger.dart';
import '../../system/threading/cancellation_token.dart';
import '../tools/ai_tool.dart';
import 'delegating_realtime_client.dart';
import 'function_invoking_realtime_client_session.dart';
import 'realtime_client_session.dart';
import 'realtime_session_options.dart';

/// A delegating real-time client that automatically invokes functions
/// requested by the model.
///
/// Sessions created by this client are wrapped in a
/// [FunctionInvokingRealtimeClientSession]. When a session receives a function
/// call in a server message, the corresponding [AIFunction] (from
/// [RealtimeSessionOptions.tools] or [additionalTools]) is invoked and the
/// result is sent back to the model, repeating until no further function calls
/// are produced or a stop condition is met, such as reaching
/// [maximumIterationsPerRequest].
///
/// This is an experimental feature.
@Source(
  name: 'FunctionInvokingRealtimeClient.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI/Realtime/',
  commit: '2e537166e4231e50cceb66832b9dfd1382e24d1b',
)
class FunctionInvokingRealtimeClient extends DelegatingRealtimeClient {
  /// Creates a new [FunctionInvokingRealtimeClient].
  FunctionInvokingRealtimeClient(
    super.innerClient, {
    this.logger,
  });

  /// An optional logger for diagnostic output about function invocation.
  final Logger? logger;

  /// Whether to include detailed error information in function results sent
  /// back to the model.
  ///
  /// Defaults to `false`, in which case a generic error message is sent
  /// instead of the actual exception details.
  bool includeDetailedErrors = false;

  /// Whether to allow concurrent invocation of multiple function calls within
  /// a single response.
  ///
  /// Defaults to `false`.
  bool allowConcurrentInvocation = false;

  /// The maximum number of function-invocation iterations per response.
  ///
  /// Once reached, further function calls are passed through without being
  /// invoked. Defaults to 40.
  int maximumIterationsPerRequest = 40;

  /// The maximum number of consecutive iterations allowed to fail with an
  /// error before the loop stops.
  ///
  /// Defaults to 3.
  int maximumConsecutiveErrorsPerRequest = 3;

  /// Additional tools available for invocation beyond those in
  /// [RealtimeSessionOptions.tools].
  List<AITool>? additionalTools;

  /// Whether to terminate the loop when a function call references a tool that
  /// is not available.
  ///
  /// Defaults to `false`, in which case a "not found" result is sent back to
  /// the model rather than ending the response.
  bool terminateOnUnknownCalls = false;

  @override
  Future<RealtimeClientSession> createSession({
    RealtimeSessionOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    final innerSession = await super.createSession(
      options: options,
      cancellationToken: cancellationToken,
    );
    return FunctionInvokingRealtimeClientSession(innerSession, this);
  }
}
