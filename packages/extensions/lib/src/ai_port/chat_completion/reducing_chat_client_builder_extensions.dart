import '../../../../../lib/func_typedefs.dart';
import '../abstractions/chat_reduction/chat_reducer.dart';
import 'chat_client_builder.dart';
import 'reducing_chat_client.dart';

/// Provides extension methods for attaching a [ReducingChatClient] to a chat
/// pipeline.
extension ReducingChatClientBuilderExtensions on ChatClientBuilder {
  /// Adds a [ReducingChatClient] to the chat pipeline.
///
/// Returns: The configured [ChatClientBuilder] instance.
///
/// [builder] The [ChatClientBuilder] being used to build the chat pipeline.
///
/// [reducer] An optional [ChatReducer] to apply to the chat client. If not
/// supplied, an instance will be resolved from the service provider.
///
/// [configure] An optional callback that can be used to configure the
/// [ReducingChatClient] instance.
ChatClientBuilder useChatReducer({ChatReducer? reducer, Action<ReducingChatClient>? configure, }) {
_ = Throw.ifNull(builder);
return builder.use((innerClient, services) =>
        {
            reducer ??= services.getRequiredService<ChatReducer>();

            var chatClient = reducingChatClient(innerClient, reducer);
            configure?.invoke(chatClient);
            return chatClient;
        });
 }
 }
