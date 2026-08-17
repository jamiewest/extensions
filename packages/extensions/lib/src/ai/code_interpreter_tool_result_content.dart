import 'ai_content.dart';
import 'tool_result_content.dart';

/// Represents the result of a code interpreter tool invocation by a hosted
/// service.
///
/// Outputs can include [DataContent] for binary data, text output, or
/// [HostedFileContent] for generated files.
class CodeInterpreterToolResultContent extends ToolResultContent {
  /// Creates a new [CodeInterpreterToolResultContent].
  CodeInterpreterToolResultContent({
    required super.callId,
    this.outputs,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// The output contents produced by the code interpreter tool.
  List<AIContent>? outputs;
}
