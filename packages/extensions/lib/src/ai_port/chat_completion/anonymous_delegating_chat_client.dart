import '../../../../../lib/func_typedefs.dart';
import '../abstractions/chat_completion/chat_client.dart';
import '../abstractions/chat_completion/chat_message.dart';
import '../abstractions/chat_completion/chat_options.dart';
import '../abstractions/chat_completion/chat_response_update.dart';
import '../abstractions/chat_completion/delegating_chat_client.dart';

/// Represents a delegating chat client that wraps an inner client with
/// implementations provided by delegates.
class AnonymousDelegatingChatClient extends DelegatingChatClient {
  /// Initializes a new instance of the [AnonymousDelegatingChatClient] class.
  ///
  /// Remarks: This overload may be used when the anonymous implementation needs
  /// to provide pre-processing and/or post-processing, but doesn't need to
  /// interact with the results of the operation, which will come from the inner
  /// client.
  ///
  /// [innerClient] The inner client.
  ///
  /// [sharedFunc] A delegate that provides the implementation for both
  /// [CancellationToken)] and [CancellationToken)]. In addition to the
  /// arguments for the operation, it's provided with a delegate to the inner
  /// client that should be used to perform the operation on the inner client.
  /// It will handle both the non-streaming and streaming cases.
  AnonymousDelegatingChatClient(
    ChatClient innerClient, {
    Func4<
          Iterable<ChatMessage>,
          ChatOptions?,
          Func3<Iterable<ChatMessage>, ChatOptions?, CancellationToken, Future>,
          CancellationToken,
          Future
        >?
        sharedFunc =
        null,
    Func4<
          Iterable<ChatMessage>,
          ChatOptions?,
          ChatClient,
          CancellationToken,
          Future<ChatResponse>
        >?
        getResponseFunc =
        null,
    Func4<
          Iterable<ChatMessage>,
          ChatOptions?,
          ChatClient,
          CancellationToken,
          Stream<ChatResponseUpdate>
        >?
        getStreamingResponseFunc =
        null,
  }) : _sharedFunc = sharedFunc {
    _ = Throw.ifNull(sharedFunc);
  }

  /// The delegate to use as the implementation of [CancellationToken)].
  final Func4<
    Iterable<ChatMessage>,
    ChatOptions?,
    ChatClient,
    CancellationToken,
    Future<ChatResponse>
  >?
  _getResponseFunc;

  /// The delegate to use as the implementation of [CancellationToken)].
  ///
  /// Remarks: When non-`null`, this delegate is used as the implementation of
  /// [CancellationToken)] and will be invoked with the same arguments as the
  /// method itself, along with a reference to the inner client. When `null`,
  /// [CancellationToken)] will delegate directly to the inner client.
  final Func4<
    Iterable<ChatMessage>,
    ChatOptions?,
    ChatClient,
    CancellationToken,
    Stream<ChatResponseUpdate>
  >?
  _getStreamingResponseFunc;

  /// The delegate to use as the implementation of both [CancellationToken)] and
  /// [CancellationToken)].
  final Func4<
    Iterable<ChatMessage>,
    ChatOptions?,
    Func3<Iterable<ChatMessage>, ChatOptions?, CancellationToken, Future>,
    CancellationToken,
    Future
  >?
  _sharedFunc;

  @override
  Future<ChatResponse> getResponse(
    Iterable<ChatMessage> messages, {
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) {
    _ = Throw.ifNull(messages);
    if (_sharedFunc != null) {
      return getResponseViaSharedAsync(messages, options, cancellationToken);
      /* TODO: unsupported node kind "unknown" */
      // async Task<ChatResponse> GetResponseViaSharedAsync(
      //                 IEnumerable<ChatMessage> messages, ChatOptions? options, CancellationToken cancellationToken)
      //             {
      //                 ChatResponse? response = null;
      //                 await _sharedFunc(messages, options, async (messages, options, cancellationToken) =>
      //                 {
      //                     response = await InnerClient.GetResponseAsync(messages, options, cancellationToken);
      //                 }, cancellationToken);
      //
      //                 if (response is null)
      //                 {
      //                     Throw.InvalidOperationException("The wrapper completed successfully without producing a ChatResponse.");
      //                 }
      //
      //                 return response;
      //             }
    } else if (_getResponseFunc != null) {
      return _getResponseFunc(
        messages,
        options,
        InnerClient,
        cancellationToken,
      );
    } else {
      Debug.assertValue(
        _getStreamingResponseFunc != null,
        "Expected non-null streaming delegate.",
      );
      return _getStreamingResponseFunc!(
        messages,
        options,
        InnerClient,
        cancellationToken,
      ).toChatResponseAsync(cancellationToken);
    }
  }

  @override
  Stream<ChatResponseUpdate> getStreamingResponse(
    Iterable<ChatMessage> messages, {
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) {
    _ = Throw.ifNull(messages);
    if (_sharedFunc != null) {
      var updates = Channel.createBounded<ChatResponseUpdate>(1);
      _ = processAsync();
      /* TODO: unsupported node kind "unknown" */
      // async Task ProcessAsync()
      //             {
      //                 Exception? error = null;
      //                 try
      //                 {
      //                     await _sharedFunc(messages, options, async (messages, options, cancellationToken) =>
      //                     {
      //                         await foreach (var update in InnerClient.GetStreamingResponseAsync(messages, options, cancellationToken))
      //                         {
      //                             await updates.Writer.WriteAsync(update, cancellationToken);
      //                         }
      //                     }, cancellationToken);
      //                 }
      //                 catch (Exception ex)
      //                 {
      //                     error = ex;
      //                     throw;
      //                 }
      //                 finally
      //                 {
      //                     _ = updates.Writer.TryComplete(error);
      //                 }
      //             }
      return readAllAsync(updates, cancellationToken);
      /* TODO: unsupported node kind "unknown" */
      // static async IAsyncEnumerable<ChatResponseUpdate> ReadAllAsync(
      //                 ChannelReader<ChatResponseUpdate> channel, [EnumeratorCancellation] CancellationToken cancellationToken)
      //             {
      //                 while (await channel.WaitToReadAsync(cancellationToken))
      //                 {
      //                     while (channel.TryRead(out var update))
      //                     {
      //                         yield return update;
      //                     }
      //                 }
      //             }
    } else if (_getStreamingResponseFunc != null) {
      return _getStreamingResponseFunc(
        messages,
        options,
        InnerClient,
        cancellationToken,
      );
    } else {
      Debug.assertValue(
        _getResponseFunc != null,
        "Expected non-null non-streaming delegate.",
      );
      return getStreamingResponseAsyncViaGetResponseAsync(
        _getResponseFunc!(messages, options, InnerClient, cancellationToken),
      );
      /* TODO: unsupported node kind "unknown" */
      // static async IAsyncEnumerable<ChatResponseUpdate> GetStreamingResponseAsyncViaGetResponseAsync(Task<ChatResponse> task)
      //             {
      //                 ChatResponse response = await task;
      //                 foreach (var update in response.ToChatResponseUpdates())
      //                 {
      //                     yield return update;
      //                 }
      //             }
    }
  }

  /// Throws an exception if both of the specified delegates are `null`.
  static void throwIfBothDelegatesNull(
    Object? getResponseFunc,
    Object? getStreamingResponseFunc,
  ) {
    if (getResponseFunc == null && getStreamingResponseFunc == null) {
      Throw.argumentNullException(
        nameof(getResponseFunc),
        'At least one of the ${nameof(getResponseFunc)} or ${nameof(getStreamingResponseFunc)} delegates must be non-null.',
      );
    }
  }
}
