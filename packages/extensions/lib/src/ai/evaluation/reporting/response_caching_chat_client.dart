import 'package:extensions/annotations.dart';

import '../../../system/threading/cancellation_token.dart';
import '../../chat_completion/caching_chat_client.dart';
import '../../chat_completion/chat_message.dart';
import '../../chat_completion/chat_options.dart';
import '../../chat_completion/chat_response.dart';
import 'chat_details.dart';
import 'chat_turn_details.dart';
import 'response_cache.dart';

/// A [CachingChatClient] that persists responses to a [ResponseCache] and
/// records per-turn latency and usage in a [ChatDetails] object.
@Source(
  name: 'ResponseCachingChatClient.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Reporting',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Reporting/',
)
class ResponseCachingChatClient extends CachingChatClient {
  /// Creates a [ResponseCachingChatClient].
  ResponseCachingChatClient(
    super.innerClient, {
    required ResponseCache cache,
    required ChatDetails chatDetails,
    List<String>? cachingKeys,
  })  : _cache = cache,
        _chatDetails = chatDetails,
        _cachingKeys = cachingKeys ?? [];

  final ResponseCache _cache;
  final ChatDetails _chatDetails;
  final List<String> _cachingKeys;

  @override
  String getCacheKey(Iterable<ChatMessage> messages, ChatOptions? options) {
    final buffer = StringBuffer(super.getCacheKey(messages, options));
    for (final key in _cachingKeys) {
      buffer.write('|$key');
    }
    return buffer.toString();
  }

  @override
  Future<ChatResponse?> getCachedResponse(String key) async {
    final stopwatch = Stopwatch()..start();
    final response = await _cache.get(key);
    stopwatch.stop();
    if (response != null) {
      _chatDetails.addTurnDetails(ChatTurnDetails(
        latency: stopwatch.elapsed,
        model: response.modelId,
        usage: response.usage,
        cacheKey: key,
        cacheHit: true,
      ));
    }
    return response;
  }

  @override
  Future<void> setCachedResponse(String key, ChatResponse response) =>
      _cache.set(key, response);

  @override
  Future<ChatResponse> getResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    final stopwatch = Stopwatch()..start();
    final response = await super.getResponse(
      messages: messages,
      options: options,
      cancellationToken: cancellationToken,
    );
    stopwatch.stop();
    final cached = await getCachedResponse(getCacheKey(messages, options));
    if (cached == null) {
      _chatDetails.addTurnDetails(ChatTurnDetails(
        latency: stopwatch.elapsed,
        model: response.modelId,
        usage: response.usage,
        cacheHit: false,
      ));
    }
    return response;
  }
}
