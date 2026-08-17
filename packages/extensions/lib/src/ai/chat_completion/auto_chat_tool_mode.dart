import 'chat_tool_mode.dart';

/// Indicates that a chat client is free to select any of the available tools,
/// or none at all.
///
/// Use [ChatToolMode.auto] to get an instance of [AutoChatToolMode].
final class AutoChatToolMode extends ChatToolMode {
  /// Creates a new [AutoChatToolMode].
  ///
  /// Use [ChatToolMode.auto] to get a shared instance.
  const AutoChatToolMode();

  @override
  bool operator ==(Object other) => other is AutoChatToolMode;

  @override
  int get hashCode => runtimeType.hashCode;
}
