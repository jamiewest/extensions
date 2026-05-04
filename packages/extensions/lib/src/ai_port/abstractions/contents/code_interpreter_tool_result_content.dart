import 'ai_content.dart';
import 'data_content.dart';
import 'hosted_file_content.dart';
import 'text_content.dart';
import 'tool_result_content.dart';

/// Represents the result of a code interpreter tool invocation by a hosted
/// service.
class CodeInterpreterToolResultContent extends ToolResultContent {
  /// Initializes a new instance of the [CodeInterpreterToolResultContent]
  /// class.
  ///
  /// [callId] The tool call ID.
  const CodeInterpreterToolResultContent(String callId);

  /// Gets or sets the output of code interpreter tool.
  ///
  /// Remarks: Outputs can include various types of content such as
  /// [HostedFileContent] for files, [DataContent] for binary data,
  /// [TextContent] for standard output text, or other [AIContent] types as
  /// supported by the service.
  List<AContent>? outputs;
}
