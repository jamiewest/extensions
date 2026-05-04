import '../../../abstractions/chat_completion/chat_message.dart';
import '../../../abstractions/chat_completion/chat_options.dart';
import '../../chat_configuration.dart';

class JsonOutputFixer {
  JsonOutputFixer();

  static ReadOnlySpan<char> trimMarkdownDelimiters(String json) {
    var trimmed = json.toCharArray();
    #endif

        // Trim whitespace and markdown characters from beginning and end.
        trimmed = trimmed.trim().trim(['`']);
    var JsonMarker = "json";
    var markerLength = JsonMarker.length;
    if (trimmed.length > markerLength && trimmed.slice(0, markerLength).sequenceEqual(JsonMarker.asSpan())) {
      trimmed = trimmed.slice(markerLength);
    }
    return trimmed;
  }

  static Future<String> repairJson(
    String json,
    ChatConfiguration chatConfig,
    CancellationToken cancellationToken,
  ) async  {
    var SystemPrompt = """
            You are an AI assistant. Your job is to fix any syntax errors in a supplied JSON object so that it conforms
            strictly to the JSON standard. Your response should include just the fixed JSON object and nothing else.
            """;
    var fixPrompt = ''"
            Fix the following JSON object. Return exactly the same JSON object with the same data content but with any
            syntax errors corrected.

            If the supplied text includes any markdown delimiters around the JSON object, strip out the markdown
            delimiters and return just the fixed JSON object. Your response should start with an open curly brace and
            end with a closing curly brace.
            ---
            {json}
            """;
    var chatOptions = chatOptions();
    var messages = List<ChatMessage>();
    var response = await chatConfig.chatClient.getResponseAsync(
                messages,
                chatOptions,
                cancellationToken: cancellationToken).configureAwait(false);
    return response.text.trim();
  }
}
