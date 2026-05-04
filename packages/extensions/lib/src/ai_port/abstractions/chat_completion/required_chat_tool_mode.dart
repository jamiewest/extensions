import 'chat_tool_mode.dart';

/// Represents a mode where a chat tool must be called. This class can
/// optionally nominate a specific function or indicate that any of the
/// functions can be selected.
class RequiredChatToolMode extends ChatToolMode {
  /// Initializes a new instance of the [RequiredChatToolMode] class that
  /// requires a specific tool to be called.
  ///
  /// Remarks: `requiredFunctionName` can be `null`. However, it's preferable to
  /// use [RequireAny] when any function can be selected.
  ///
  /// [requiredFunctionName] The name of the tool that must be called.
  RequiredChatToolMode(String? requiredFunctionName) : requiredFunctionName = requiredFunctionName {
    if (requiredFunctionName != null) {
      _ = Throw.ifNullOrWhitespace(requiredFunctionName);
    }
  }

  /// Gets the name of a specific tool that must be called.
  ///
  /// Remarks: If the value is `null`, any available tool can be selected (but
  /// at least one must be).
  final String? requiredFunctionName;

  /// Gets a string representing this instance to display in the debugger.
  String get debuggerDisplay {
    return 'Required: ${requiredFunctionName ?? "Any"}';
  }

  @override
  bool equals(Object? obj) {
    return obj is RequiredChatToolMode other &&
        requiredFunctionName == other.requiredFunctionName;
  }

  @override
  int getHashCode() {
    return requiredFunctionName?.getHashCode(StringComparison.ordinal) ??
        typeof(RequiredChatToolMode).getHashCode();
  }
}
