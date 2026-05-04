import 'package:extensions/annotations.dart';

import 'ai_content.dart';
import 'tool_call_content.dart';

/// Represents a code interpreter tool call invoked by a hosted service.
///
/// This is informational only and represents the call itself, not its result.
/// Inputs typically include a [DataContent] with media type `text/x-python`.
@Source(
  name: 'CodeInterpreterToolCallContent.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Contents/',
)
class CodeInterpreterToolCallContent extends ToolCallContent {
  /// Creates a new [CodeInterpreterToolCallContent].
  CodeInterpreterToolCallContent({
    required super.callId,
    this.inputs,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// The inputs provided to the code interpreter tool.
  List<AIContent>? inputs;
}
