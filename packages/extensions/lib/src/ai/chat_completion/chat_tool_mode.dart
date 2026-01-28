/// Represents the mode in which tools are used by the chat client.
sealed class ChatToolMode {
  const ChatToolMode._();

  /// Tools may optionally be used by the model.
  static const AutoChatToolMode auto = AutoChatToolMode();

  /// No tools should be used by the model.
  static const NoneChatToolMode none = NoneChatToolMode();

  /// The model must call at least one tool (any tool).
  static const RequiredChatToolMode requireAny = RequiredChatToolMode();

  /// The model must call the specified function.
  static RequiredChatToolMode requireSpecific(String functionName) =>
      RequiredChatToolMode(requiredFunctionName: functionName);
}

/// Tools may optionally be used by the model.
final class AutoChatToolMode extends ChatToolMode {
  const AutoChatToolMode() : super._();

  @override
  bool operator ==(Object other) => other is AutoChatToolMode;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// No tools should be used by the model.
final class NoneChatToolMode extends ChatToolMode {
  const NoneChatToolMode() : super._();

  @override
  bool operator ==(Object other) => other is NoneChatToolMode;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// The model must call at least one tool.
final class RequiredChatToolMode extends ChatToolMode {
  const RequiredChatToolMode({this.requiredFunctionName}) : super._();

  /// The specific function name that must be called, or `null` for any tool.
  final String? requiredFunctionName;

  @override
  bool operator ==(Object other) =>
      other is RequiredChatToolMode &&
      requiredFunctionName == other.requiredFunctionName;

  @override
  int get hashCode => Object.hash(runtimeType, requiredFunctionName);
}
