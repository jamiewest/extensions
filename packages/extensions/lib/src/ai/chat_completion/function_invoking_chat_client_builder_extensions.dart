import 'package:extensions/extensions.dart';

import 'chat_client_builder.dart';

typedef ConfigureFunctionInvokingChatClient = void Function(
    FunctionInvokingChatClient client);

/// Provides extension methods for attaching a [FunctionInvokingChatClient]
/// to a chat pipeline.
extension FunctionInvokingChatClientBuilderExtensions on ChatClientBuilder {
  ChatClientBuilder useFunctionInvocation(
      {LoggerFactory? loggerfactory,
      ConfigureFunctionInvokingChatClient? configure}) {}
}
