import 'chat_client.dart';
import 'chat_tool_mode.dart';

/// Indicates that an [ChatClient] should not request the invocation of any
/// tools.
///
/// Remarks: Use [None] to get an instance of [NoneChatToolMode].
class NoneChatToolMode extends ChatToolMode {
  /// Initializes a new instance of the [NoneChatToolMode] class.
  ///
  /// Remarks: Use [None] to get an instance of [NoneChatToolMode].
  const NoneChatToolMode();

  @override
  bool equals(Object? obj) {
    return obj is NoneChatToolMode;
  }

  @override
  int getHashCode() {
    return typeof(NoneChatToolMode).getHashCode();
  }
}
