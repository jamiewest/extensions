import 'chat_client_builder.dart';
import 'function_invoking_chat_client.dart';

typedef ConfigureFunctionInvokingChatClient = void Function(
    FunctionInvokingChatClient client);

/// Extension methods for adding [FunctionInvokingChatClient] to a pipeline.
extension FunctionInvokingChatClientBuilderExtensions on ChatClientBuilder {
  /// Adds a [FunctionInvokingChatClient] to the pipeline.
  ChatClientBuilder useFunctionInvocation({
    ConfigureFunctionInvokingChatClient? configure,
  }) =>
      use((inner) {
        final client = FunctionInvokingChatClient(inner);
        configure?.call(client);
        return client;
      });
}
