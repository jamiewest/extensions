import 'chat_tool_mode.dart';
import '../../../annotations.dart';

/// Indicates that a chat client is free to select any of the available tools,
/// or none at all.
///
/// Use [ChatToolMode.auto] to get an instance of [AutoChatToolMode].
@Source(
  name: 'AutoChatToolMode.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/ChatCompletion/',
  commit: '01a52dd763da02f75bf1cd604e98c3e7c8508a5d',
)
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
