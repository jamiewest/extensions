import '../../../abstractions/chat_completion/chat_client.dart';
import '../../../abstractions/chat_completion/chat_client_metadata.dart';
import '../../../abstractions/chat_completion/chat_message.dart';
import '../../../abstractions/chat_completion/chat_options.dart';
import '../../../abstractions/chat_completion/chat_response_update.dart';
import '../../../abstractions/chat_completion/delegating_chat_client.dart';
import '../../utilities/model_info.dart';
import 'chat_details.dart';
import 'chat_turn_details.dart';

class SimpleChatClient extends DelegatingChatClient {
  const SimpleChatClient(ChatClient originalChatClient, ChatDetails chatDetails)
    : _chatDetails = chatDetails,
      _metadata = this.getService<ChatClientMetadata>();

  final ChatDetails _chatDetails;

  final ChatClientMetadata? _metadata;

  @override
  Future<ChatResponse> getResponse(
    Iterable<ChatMessage> messages, {
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    var response = null;
    var stopwatch = Stopwatch.startNew();
    try {
      response = await base
          .getResponseAsync(messages, options, cancellationToken)
          .configureAwait(false);
    } finally {
      stopwatch.stop();
      if (response != null) {
        var model = response.modelId;
        var modelProvider = ModelInfo.getModelProvider(model, _metadata);
        _chatDetails.addTurnDetails(
          chatTurnDetails(
            latency: stopwatch.elapsed,
            model,
            modelProvider,
            usage: response.usage,
          ),
        );
      }
    }
    return response;
  }

  @override
  Stream<ChatResponseUpdate> getStreamingResponse(
    Iterable<ChatMessage> messages, {
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    var updates = null;
    var stopwatch = Stopwatch.startNew();
    try {
      for (final update
          in base
              .getStreamingResponseAsync(messages, options, cancellationToken)
              .configureAwait(false)) {
        updates ??= [];
        updates.add(update);
        yield update;
      }
    } finally {
      stopwatch.stop();
      if (updates != null) {
        var response = updates.toChatResponse();
        var model = response.modelId;
        var modelProvider = ModelInfo.getModelProvider(model, _metadata);
        _chatDetails.addTurnDetails(
          chatTurnDetails(
            latency: stopwatch.elapsed,
            model,
            modelProvider,
            usage: response.usage,
          ),
        );
      }
    }
  }
}
