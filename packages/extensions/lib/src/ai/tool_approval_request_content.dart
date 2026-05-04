import 'package:extensions/annotations.dart';

import 'input_request_content.dart';
import 'tool_approval_response_content.dart';
import 'tool_call_content.dart';

/// Represents a request for approval before a tool call is executed.
///
/// Pair a [ToolApprovalRequestContent] with a [ToolApprovalResponseContent]
/// using the same [requestId] to implement user-in-the-loop tool approval.
@Source(
  name: 'ToolApprovalRequestContent.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Contents/',
)
class ToolApprovalRequestContent extends InputRequestContent {
  /// Creates a new [ToolApprovalRequestContent].
  ToolApprovalRequestContent({
    required super.requestId,
    required this.toolCall,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// The tool call that requires approval before execution.
  final ToolCallContent toolCall;

  /// Creates the corresponding [ToolApprovalResponseContent].
  ToolApprovalResponseContent createResponse(bool approved, {String? reason}) =>
      ToolApprovalResponseContent(
        requestId: requestId,
        approved: approved,
        toolCall: toolCall,
        reason: reason,
      );
}
