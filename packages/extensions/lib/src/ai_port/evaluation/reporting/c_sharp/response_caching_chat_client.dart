import '../../../abstractions/chat_completion/chat_client.dart';
import '../../../abstractions/chat_completion/chat_client_metadata.dart';
import '../../../abstractions/chat_completion/chat_response_update.dart';
import '../../../chat_completion/distributed_caching_chat_client.dart';
import '../../utilities/model_info.dart';
import 'chat_details.dart';
import 'chat_turn_details.dart';

class ResponseCachingChatClient extends DistributedCachingChatClient {
  ResponseCachingChatClient(
    ChatClient originalChatClient,
    DistributedCache cache,
    Iterable<String> cachingKeys,
    ChatDetails chatDetails,
  ) :
      _chatDetails = chatDetails,
      _stopWatches = new ConcurrentDictionary<String, Stopwatch>(),
      _metadata = this.getService<ChatClientMetadata>() {
    CacheKeyAdditionalValues = [.. cachingKeys];
  }

  final ChatDetails _chatDetails;

  final ConcurrentDictionary<String, Stopwatch> _stopWatches;

  final ChatClientMetadata? _metadata;

  @override
  Future<ChatResponse?> readCache(String key, CancellationToken cancellationToken, ) async  {
    var stopwatch = Stopwatch.startNew();
    var response = await base.readCacheAsync(key, cancellationToken).configureAwait(false);
    if (response == null) {
      _ = _stopWatches.addOrUpdate(
        key,
        addValue: stopwatch,
        updateValueFactory: (_, _) => stopwatch,
      );
    } else {
      stopwatch.stop();
      var model = response.modelId;
      var modelProvider = ModelInfo.getModelProvider(model, _metadata);
      _chatDetails.addTurnDetails(
                chatTurnDetails(
                    latency: stopwatch.elapsed,
                    model,
                    modelProvider,
                    usage: response.usage,
                    cacheKey: key,
                    cacheHit: true));
    }
    return response;
  }

  @override
  Future<List<ChatResponseUpdate>?> readCacheStreaming(
    String key,
    CancellationToken cancellationToken,
  ) async  {
    var stopwatch = Stopwatch.startNew();
    var updates = await base.readCacheStreamingAsync(key, cancellationToken).configureAwait(false);
    if (updates == null) {
      _ = _stopWatches.addOrUpdate(
        key,
        addValue: stopwatch,
        updateValueFactory: (_, _) => stopwatch,
      );
    } else {
      stopwatch.stop();
      var response = updates.toChatResponse();
      var model = response.modelId;
      var modelProvider = ModelInfo.getModelProvider(model, _metadata);
      _chatDetails.addTurnDetails(
                chatTurnDetails(
                    latency: stopwatch.elapsed,
                    model,
                    modelProvider,
                    usage: response.usage,
                    cacheKey: key,
                    cacheHit: true));
    }
    return updates;
  }

  @override
  Future writeCache(String key, ChatResponse value, CancellationToken cancellationToken, ) async  {
    await base.writeCacheAsync(key, value, cancellationToken).configureAwait(false);
    Stopwatch? stopwatch;
    if (_stopWatches.tryRemove(key)) {
      stopwatch.stop();
      var model = value.modelId;
      var modelProvider = ModelInfo.getModelProvider(model, _metadata);
      _chatDetails.addTurnDetails(
                chatTurnDetails(
                    latency: stopwatch.elapsed,
                    model,
                    modelProvider,
                    usage: value.usage,
                    cacheKey: key,
                    cacheHit: false));
    }
  }

  @override
  Future writeCacheStreaming(
    String key,
    List<ChatResponseUpdate> value,
    CancellationToken cancellationToken,
  ) async  {
    await base.writeCacheStreamingAsync(key, value, cancellationToken).configureAwait(false);
    Stopwatch? stopwatch;
    if (_stopWatches.tryRemove(key)) {
      stopwatch.stop();
      var response = value.toChatResponse();
      var model = response.modelId;
      var modelProvider = ModelInfo.getModelProvider(model, _metadata);
      _chatDetails.addTurnDetails(
                chatTurnDetails(
                    latency: stopwatch.elapsed,
                    model,
                    modelProvider,
                    usage: response.usage,
                    cacheKey: key,
                    cacheHit: false));
    }
  }
}
