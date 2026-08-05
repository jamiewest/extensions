import 'package:extensions/annotations.dart';

import '../../system/threading/cancellation_token.dart';
import '../chat_completion/chat_client.dart';
import 'failover_chat_client.dart';
import 'failover_chat_client_attempt.dart';
import 'routing_context.dart';

/// Provides ordered failover across a sequence of chat clients.
///
/// The clients are tried in order. An invocation failure before streaming
/// output is exposed advances to the next client. Cancellation and
/// failures after streaming output is exposed are propagated without
/// failover.
///
/// The configured clients are snapshotted by the constructor. The same
/// client may appear more than once, in which case it is invoked once per
/// position. When every client has failed, the final failure is rethrown.
///
/// Upstream marks the ChatRouting family `[Experimental]`; the surface
/// may change as upstream stabilizes.
@Source(
  name: 'OrderedFailoverChatClient.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI/ChatRouting/',
)
final class OrderedFailoverChatClient extends FailoverChatClient {
  /// Creates a new [OrderedFailoverChatClient] over [clients], in
  /// fallback order.
  ///
  /// When [leaveOpen] is `true`, the inner clients are left open when this
  /// instance is disposed.
  ///
  /// Throws [ArgumentError] when [clients] is empty.
  OrderedFailoverChatClient(
    List<ChatClient> clients, {
    bool leaveOpen = false,
  })  : _leaveOpen = leaveOpen,
        _clients = List.unmodifiable(clients) {
    if (_clients.isEmpty) {
      throw ArgumentError.value(
        clients,
        'clients',
        'At least one client must be provided.',
      );
    }
  }

  final bool _leaveOpen;
  final List<ChatClient> _clients;

  // Holds the next client index for a request that has a failed attempt.
  // A nonterminal update is always followed by another selection, so a
  // stored index is always in range. Contexts are compared by identity.
  final Map<RoutingContext, int> _requestStates = Map.identity();

  bool _disposed = false;

  @override
  Future<ChatClient> selectClient(
    RoutingContext context,
    CancellationToken? cancellationToken,
  ) async =>
      _clients[_requestStates[context] ?? 0];

  @override
  Future<void> onRoutingUpdate(
    RoutingContext context,
    FailoverChatClientAttempt attempt, {
    required bool isTerminal,
    CancellationToken? cancellationToken,
  }) async {
    if (isTerminal) {
      _requestStates.remove(context);
      return;
    }

    assert(
      attempt.exception != null,
      'A nonterminal update always reports a failed invocation.',
    );

    final nextClientIndex = (_requestStates[context] ?? 0) + 1;
    if (nextClientIndex < _clients.length) {
      _requestStates[context] = nextClientIndex;
      return;
    }

    // Every client has failed. Release the state before the final failure
    // ends routing.
    _requestStates.remove(context);
    final exception = attempt.exception;
    if (exception != null) {
      Error.throwWithStackTrace(
        exception,
        attempt.stackTrace ?? StackTrace.current,
      );
    }
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }

    _disposed = true;
    _requestStates.clear();

    if (!_leaveOpen) {
      for (final client in _clients) {
        client.dispose();
      }
    }

    super.dispose();
  }
}
