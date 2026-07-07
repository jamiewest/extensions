import '../chat_reduction/chat_reducer.dart';
import 'chat_client_builder.dart';
import 'reducing_chat_client.dart';

/// Provides extensions for adding [ReducingChatClient] to a
/// [ChatClientBuilder] pipeline.
extension ReducingChatClientBuilderExtensions on ChatClientBuilder {
  /// Adds a [ReducingChatClient] that reduces message history via [reducer]
  /// before forwarding each request.
  ChatClientBuilder useChatReducer(ChatReducer reducer) =>
      use((inner) => ReducingChatClient(inner, reducer: reducer));
}
