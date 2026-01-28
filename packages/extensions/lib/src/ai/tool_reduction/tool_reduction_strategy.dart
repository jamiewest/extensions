import '../../system/threading/cancellation_token.dart';
import '../chat_completion/chat_message.dart';
import '../chat_completion/chat_options.dart';
import '../tools/ai_tool.dart';

/// Represents a strategy capable of selecting a reduced set of tools for a
/// chat request.
abstract class ToolReductionStrategy {
  /// Selects the tools that should be included for a specific request.
  Future<Iterable<AITool>> selectToolsForRequest(
    Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken cancellationToken,
  );
}
