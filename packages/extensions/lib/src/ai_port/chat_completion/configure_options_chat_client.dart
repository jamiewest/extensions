import '../../../../../lib/func_typedefs.dart';
import '../abstractions/chat_completion/chat_client.dart';
import '../abstractions/chat_completion/chat_message.dart';
import '../abstractions/chat_completion/chat_options.dart';
import '../abstractions/chat_completion/chat_response_update.dart';
import '../abstractions/chat_completion/delegating_chat_client.dart';

/// Represents a delegating chat client that configures a [ChatOptions]
/// instance used by the remainder of the pipeline.
class ConfigureOptionsChatClient extends DelegatingChatClient {
  /// Initializes a new instance of the [ConfigureOptionsChatClient] class with
  /// the specified `configure` callback.
  ///
  /// Remarks: The `configure` delegate is passed either a new instance of
  /// [ChatOptions] if the caller didn't supply a [ChatOptions] instance, or a
  /// clone (via [Clone] of the caller-supplied instance if one was supplied.
  ///
  /// [innerClient] The inner client.
  ///
  /// [configure] The delegate to invoke to configure the [ChatOptions]
  /// instance. It is passed a clone of the caller-supplied [ChatOptions]
  /// instance (or a newly constructed instance if the caller-supplied instance
  /// is `null`).
  const ConfigureOptionsChatClient(
    ChatClient innerClient,
    Action<ChatOptions> configure,
  ) : _configureOptions = Throw.ifNull(configure);

  /// The callback delegate used to configure options.
  final Action<ChatOptions> _configureOptions;

  @override
  Future<ChatResponse> getResponse(
    Iterable<ChatMessage> messages,
    {ChatOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    return await base.getResponseAsync(messages, configure(options), cancellationToken);
  }

  @override
  Stream<ChatResponseUpdate> getStreamingResponse(
    Iterable<ChatMessage> messages,
    {ChatOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    for (final update in base.getStreamingResponseAsync(messages, configure(options), cancellationToken)) {
      yield update;
    }
  }

  /// Creates and configures the [ChatOptions] to pass along to the inner
  /// client.
  ChatOptions configure(ChatOptions? options) {
    options = options?.clone() ?? new();
    _configureOptions(options);
    return options;
  }
}
