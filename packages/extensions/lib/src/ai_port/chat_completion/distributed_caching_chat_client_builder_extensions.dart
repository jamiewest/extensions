import '../../../../../lib/func_typedefs.dart';
import '../abstractions/chat_completion/chat_client.dart';
import '../abstractions/chat_completion/chat_message.dart';
import '../abstractions/chat_completion/chat_options.dart';
import '../abstractions/chat_completion/chat_response_update.dart';
import 'chat_client_builder.dart';
import 'distributed_caching_chat_client.dart';

/// Extension methods for adding a [DistributedCachingChatClient] to an
/// [ChatClient] pipeline.
extension DistributedCachingChatClientBuilderExtensions on ChatClientBuilder {
  /// Adds a [DistributedCachingChatClient] as the next stage in the pipeline.
///
/// Remarks: The [DistributedCachingChatClient] employs JSON serialization as
/// part of storing the cached data. It is not guaranteed that the object
/// models used by [ChatMessage], [ChatOptions], [ChatResponse],
/// [ChatResponseUpdate], or any of the other objects in the chat client
/// pipeline will roundtrip through JSON serialization with full fidelity. For
/// example, [RawRepresentation] will be ignored, and [Object] values in
/// [AdditionalProperties] will deserialize as [JsonElement] rather than as
/// the original type. In general, code using [DistributedCachingChatClient]
/// should only rely on accessing data that can be preserved well enough
/// through JSON serialization and deserialization.
///
/// Returns: The [ChatClientBuilder] provided as `builder`.
///
/// [builder] The [ChatClientBuilder].
///
/// [storage] An optional [DistributedCache] instance that will be used as the
/// backing store for the cache. If not supplied, an instance will be resolved
/// from the service provider.
///
/// [configure] An optional callback that can be used to configure the
/// [DistributedCachingChatClient] instance.
ChatClientBuilder useDistributedCache({DistributedCache? storage, Action<DistributedCachingChatClient>? configure, }) {
_ = Throw.ifNull(builder);
return builder.use((innerClient, services) =>
        {
            storage ??= services.getRequiredService<DistributedCache>();
            var chatClient = distributedCachingChatClient(innerClient, storage);
            configure?.invoke(chatClient);
            return chatClient;
        });
 }
 }
