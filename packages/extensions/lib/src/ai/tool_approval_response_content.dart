import 'input_response_content.dart';
import 'tool_call_content.dart';

/// Represents a response to a [ToolApprovalRequestContent], indicating
/// whether the tool call was approved.
class ToolApprovalResponseContent extends InputResponseContent {
  /// Creates a new [ToolApprovalResponseContent].
  ToolApprovalResponseContent({
    required super.requestId,
    required this.approved,
    required this.toolCall,
    this.reason,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// Whether the tool call was approved for execution.
  final bool approved;

  /// The tool call that was subject to approval.
  final ToolCallContent toolCall;

  /// An optional reason for the approval or rejection.
  String? reason;
}
