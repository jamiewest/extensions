import '../chat_completion/chat_client_builder.dart';
import 'tool_reducing_chat_client.dart';
import 'tool_reduction_strategy.dart';

/// Extension methods for adding tool reduction middleware to a chat client pipeline.
extension ChatClientBuilderToolReductionExtensions on ChatClientBuilder {
  /// Adds tool reduction to the chat client pipeline using the specified [strategy].
  ChatClientBuilder useToolReduction(ToolReductionStrategy strategy) {
    return use((inner) => ToolReducingChatClient(inner, strategy));
  }
}
