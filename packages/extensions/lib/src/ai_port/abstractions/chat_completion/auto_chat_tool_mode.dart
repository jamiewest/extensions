import 'chat_client.dart';
import 'chat_tool_mode.dart';

/// Indicates that an [ChatClient] is free to select any of the available
/// tools, or none at all.
///
/// Remarks: Use [Auto] to get an instance of [AutoChatToolMode].
class AutoChatToolMode extends ChatToolMode {
  /// Initializes a new instance of the [AutoChatToolMode] class.
  ///
  /// Remarks: Use [Auto] to get an instance of [AutoChatToolMode].
  const AutoChatToolMode();

  @override
  bool equals(Object? obj) {
    return obj is AutoChatToolMode;
  }

  @override
  int getHashCode() {
    return typeof(AutoChatToolMode).getHashCode();
  }
}
