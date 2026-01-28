import '../ai_content.dart';
import 'ai_tool.dart';

/// A tool representing a hosted file search capability.
///
/// This is an experimental feature.
class HostedFileSearchTool extends AITool {
  /// Creates a new [HostedFileSearchTool].
  HostedFileSearchTool({
    this.inputs,
    this.maximumResultCount,
  }) : super(name: 'file_search', description: 'File search');

  /// The input content items for the file search.
  final List<AIContent>? inputs;

  /// The maximum number of results to return.
  final int? maximumResultCount;
}
