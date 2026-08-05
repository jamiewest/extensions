import 'package:extensions/annotations.dart';

import '../chat_completion/chat_message.dart';
import '../chat_completion/chat_options.dart';

/// Provides request-specific inputs to a `RoutingChatClient`.
///
/// One context is created for each call to `getResponse` and for each
/// listen on the stream returned by `getStreamingResponse`.
///
/// [chatOptions] is cloned when the context is created. It is provided
/// for client selection and is independent of both the caller's instance
/// and the options passed to the selected client.
///
/// Contexts are compared by identity; failover policies may use a context
/// as a map key to track per-request state.
///
/// Upstream marks the ChatRouting family `[Experimental]`; the surface
/// may change as upstream stabilizes.
@Source(
  name: 'RoutingContext.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/ChatRouting/',
)
class RoutingContext {
  /// Creates a new [RoutingContext].
  RoutingContext(this.messages, ChatOptions? chatOptions)
      : chatOptions = chatOptions?.clone();

  /// The messages supplied to client selection and the selected client.
  ///
  /// Selection and failover may enumerate this sequence multiple times.
  /// Callers should supply a repeatable sequence.
  final Iterable<ChatMessage> messages;

  /// A snapshot of the request options supplied to client selection.
  ///
  /// Changes do not affect the caller's instance or the options passed to
  /// the selected client. Client-specific behavior should generally be
  /// attached to the returned client.
  final ChatOptions? chatOptions;
}
