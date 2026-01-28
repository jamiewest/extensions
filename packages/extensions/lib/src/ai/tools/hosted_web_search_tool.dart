import 'ai_tool.dart';

/// A tool representing a hosted web search capability.
///
/// This is an experimental feature.
class HostedWebSearchTool extends AITool {
  /// Creates a new [HostedWebSearchTool].
  HostedWebSearchTool() : super(name: 'web_search', description: 'Web search');
}
