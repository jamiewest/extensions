import '../../system/threading/cancellation_token.dart';
import '../chat_completion/chat_client.dart';
import '../chat_completion/chat_message.dart';
import '../chat_completion/chat_options.dart';
import '../chat_completion/chat_response.dart';
import '../chat_completion/chat_response_update.dart';
import 'routing_context.dart';

/// Selects the [ChatClient] to invoke for a request.
typedef RoutingChatClientSelector = Future<ChatClient> Function(
  RoutingContext context,
  CancellationToken? cancellationToken,
);

/// Provides a template for a [ChatClient] that selects and invokes
/// another chat client.
///
/// Derived classes implement [selectClient] to supply one client for each
/// request. The selected client is invoked once, and its response or
/// failure is propagated to the caller.
///
/// The exact client instance represents the selected routing identity.
/// Caller-supplied options may vary per invocation, but they are ephemeral
/// and do not participate in that identity. Applications can use distinct
/// configured client wrappers when configurations require distinct routing
/// identities, while custom policies may maintain separate
/// application-specific grouping keys.
///
/// Upstream marks the ChatRouting family `[Experimental]`; the surface
/// may change as upstream stabilizes.
abstract class RoutingChatClient implements ChatClient {
  /// Creates a new [RoutingChatClient].
  RoutingChatClient();

  /// Creates a routing client that selects one client for each request
  /// using [clientSelector].
  ///
  /// The selected clients are caller-owned and are not disposed by the
  /// returned routing client.
  factory RoutingChatClient.fromSelector(
    RoutingChatClientSelector clientSelector,
  ) = _CallbackRoutingChatClient;

  /// Selects the client to invoke for the request.
  ///
  /// Client-specific behavior should generally be attached to the returned
  /// client. Exceptions from this method propagate to the caller.
  Future<ChatClient> selectClient(
    RoutingContext context,
    CancellationToken? cancellationToken,
  );

  @override
  Future<ChatResponse> getResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    final context = RoutingContext(messages, options);
    final client = await selectClient(context, cancellationToken);

    return client.getResponse(
      messages: context.messages,
      options: options?.clone(),
      cancellationToken: cancellationToken,
    );
  }

  @override
  Stream<ChatResponseUpdate> getStreamingResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async* {
    final context = RoutingContext(messages, options);
    final client = await selectClient(context, cancellationToken);

    yield* client.getStreamingResponse(
      messages: context.messages,
      options: options?.clone(),
      cancellationToken: cancellationToken,
    );
  }

  @override
  T? getService<T>({Object? key}) =>
      key == null && this is T ? this as T : null;

  @override
  void dispose() {}
}

class _CallbackRoutingChatClient extends RoutingChatClient {
  _CallbackRoutingChatClient(this._clientSelector);

  final RoutingChatClientSelector _clientSelector;

  @override
  Future<ChatClient> selectClient(
    RoutingContext context,
    CancellationToken? cancellationToken,
  ) => _clientSelector(context, cancellationToken);
}
