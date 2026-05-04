import '../abstractions/chat_completion/chat_options.dart';
import '../abstractions/functions/ai_function_declaration.dart';
import 'open_ai_client_extensions.dart';

/// Provides helpers for interacting with OpenAI Realtime.
class OpenARealtimeConversationClient {
  OpenARealtimeConversationClient();

  static RealtimeFunctionTool toOpenAIRealtimeFunctionTool(
    AFunctionDeclaration aiFunction, {
    ChatOptions? options,
  }) {
    var strict =
        OpenAIClientExtensions.hasStrict(aiFunction.additionalProperties) ??
        OpenAIClientExtensions.hasStrict(options?.additionalProperties);
    return realtimeFunctionTool(aiFunction.name);
  }
}
