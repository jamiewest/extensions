import '../ai_content.dart';
import 'ai_tool.dart';

/// A tool representing a hosted code interpreter capability.
///
/// This is an experimental feature.
class HostedCodeInterpreterTool extends AITool {
  /// Creates a new [HostedCodeInterpreterTool].
  HostedCodeInterpreterTool({
    this.inputs,
  }) : super(name: 'code_interpreter', description: 'Code interpreter');

  /// The input content items for the code interpreter.
  final List<AIContent>? inputs;
}
