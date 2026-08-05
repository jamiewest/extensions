import 'package:extensions/annotations.dart';

import '../chat_completion/chat_client.dart';

/// Represents one client invocation attempt performed by a
/// `FailoverChatClient`.
///
/// A completed response has [responseCompleted] set to `true` and
/// [exception] set to `null`.
///
/// A failed invocation has [responseCompleted] set to `false` and
/// [exception] set to the observed error. If a streaming caller stops
/// listening before the response ends and disposal completes successfully,
/// both [responseCompleted] and [exception] are unset.
///
/// [outputCommitted] is independent of the outcome and indicates whether
/// any streaming update was exposed to the caller.
///
/// Upstream marks the ChatRouting family `[Experimental]`; the surface
/// may change as upstream stabilizes.
@Source(
  name: 'FailoverChatClientAttempt.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI/ChatRouting/',
)
final class FailoverChatClientAttempt {
  /// Creates a new [FailoverChatClientAttempt].
  ///
  /// This API supports infrastructure; attempts are constructed by
  /// `FailoverChatClient` and reported to `onRoutingUpdate`.
  FailoverChatClientAttempt({
    required this.client,
    this.exception,
    this.stackTrace,
    required this.duration,
    this.timeToFirstUpdate,
    required this.responseCompleted,
    required this.outputCommitted,
  })  : assert(
          duration >= Duration.zero,
          'Expected a non-negative duration.',
        ),
        assert(
          timeToFirstUpdate == null ||
              (timeToFirstUpdate >= Duration.zero &&
                  timeToFirstUpdate <= duration),
          'Expected time to first update to be within the active duration.',
        ),
        assert(
          !responseCompleted || exception == null,
          'A completed response should not have an exception.',
        ),
        assert(
          outputCommitted == (timeToFirstUpdate != null),
          'Output commitment and time to first update should agree.',
        );

  /// The client that was invoked.
  final ChatClient client;

  /// The error observed while invoking or disposing the client, if any.
  ///
  /// If invocation and disposal both throw, this contains the disposal
  /// error.
  ///
  /// A `null` value does not necessarily indicate success; inspect
  /// [responseCompleted] to distinguish a completed response from a
  /// streaming response that the caller stopped consuming.
  final Object? exception;

  /// The stack trace captured with [exception], if any.
  ///
  /// Dart has no `ExceptionDispatchInfo`; the trace is carried explicitly
  /// so failover policies can rethrow without losing the original stack.
  final StackTrace? stackTrace;

  /// The time spent actively invoking the client.
  ///
  /// For streaming, time spent by the caller processing yielded updates is
  /// excluded.
  final Duration duration;

  /// The time until the first streaming update, if this was a non-empty
  /// streaming invocation.
  final Duration? timeToFirstUpdate;

  /// Whether the response completed successfully.
  ///
  /// For streaming responses, this is `false` when the caller stops
  /// listening before the response stream ends.
  final bool responseCompleted;

  /// Whether any streaming update was exposed to the caller.
  ///
  /// This is always `false` for non-streaming invocations.
  final bool outputCommitted;
}
