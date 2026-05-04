import 'ai_content.dart';
import 'data_content.dart';
import 'hosted_file_content.dart';
import 'tool_call_content.dart';

/// Represents a code interpreter tool call invocation by a hosted service.
///
/// Remarks: This content type represents when a hosted AI service invokes a
/// code interpreter tool. It is informational only and represents the call
/// itself, not the result.
class CodeInterpreterToolCallContent extends ToolCallContent {
  /// Initializes a new instance of the [CodeInterpreterToolCallContent] class.
  ///
  /// [callId] The tool call ID.
  const CodeInterpreterToolCallContent(String callId);

  /// Gets or sets the inputs to the code interpreter tool.
  ///
  /// Remarks: Inputs can include various types of content such as
  /// [HostedFileContent] for files, [DataContent] for binary data, or other
  /// [AIContent] types as supported by the service. Typically [Inputs] includes
  /// a [DataContent] with a "text/x-python" media type representing the code
  /// for execution by the code interpreter tool.
  List<AContent>? inputs;
}
