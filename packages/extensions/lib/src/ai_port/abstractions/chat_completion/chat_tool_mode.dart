import '../tools/ai_tool.dart';
import 'auto_chat_tool_mode.dart';
import 'chat_client.dart';
import 'none_chat_tool_mode.dart';
import 'required_chat_tool_mode.dart';

/// Describes how tools should be selected by a [ChatClient].
///
/// Remarks: The predefined values [Auto], [None], and [RequireAny] are
/// provided. To nominate a specific function, use [String)].
class ChatToolMode {
  /// Initializes a new instance of the [ChatToolMode] class.
  ///
  /// Remarks: Prevents external instantiation. Close the inheritance hierarchy
  /// for now until we have good reason to open it.
  const ChatToolMode();

  /// Gets a predefined [ChatToolMode] indicating that tool usage is optional.
  ///
  /// Remarks: [Tools] can contain zero or more [AITool] instances, and the
  /// [ChatClient] is free to invoke zero or more of them.
  static final AutoChatToolMode auto;

  /// Gets a predefined [ChatToolMode] indicating that tool usage is
  /// unsupported.
  ///
  /// Remarks: [Tools] can contain zero or more [AITool] instances, but the
  /// [ChatClient] should not request the invocation of any of them. This can be
  /// used when the [ChatClient] should know about tools in order to provide
  /// information about them or plan out their usage, but should not request the
  /// invocation of any of them.
  static final NoneChatToolMode none;

  /// Gets a predefined [ChatToolMode] indicating that tool usage is required,
  /// but that any tool can be selected. At least one tool must be provided in
  /// [Tools].
  static final RequiredChatToolMode requireAny = new(requiredFunctionName: null);

  /// Instantiates a [ChatToolMode] indicating that tool usage is required, and
  /// that the specified function name must be selected.
  ///
  /// Returns: An instance of [RequiredChatToolMode] for the specified function
  /// name.
  ///
  /// [functionName] The name of the required function.
  static RequiredChatToolMode requireSpecific(String functionName) {
    return new(functionName);
  }
}
