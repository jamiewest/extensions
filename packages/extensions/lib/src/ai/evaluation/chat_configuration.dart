import 'package:extensions/annotations.dart';

import '../chat_completion/chat_client.dart';

/// Specifies the [ChatClient] to use when evaluation is performed by an AI
/// model.
@Source(
  name: 'ChatConfiguration.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation/',
)
class ChatConfiguration {
  /// Creates a [ChatConfiguration] wrapping [chatClient].
  const ChatConfiguration(this.chatClient);

  /// The [ChatClient] used to communicate with an AI model during evaluation.
  final ChatClient chatClient;
}
