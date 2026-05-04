import 'input_response_content.dart';
import 'tool_approval_request_content.dart';
import 'tool_call_content.dart';

/// Represents a response to a [ToolApprovalRequestContent], indicating
/// whether the tool call was approved.
class ToolApprovalResponseContent extends InputResponseContent {
  /// Initializes a new instance of the [ToolApprovalResponseContent] class.
  ///
  /// [requestId] The unique identifier of the [ToolApprovalRequestContent]
  /// associated with this response.
  ///
  /// [approved] `true` if the tool call is approved; otherwise, `false`.
  ///
  /// [toolCall] The tool call that was subject to approval.
  const ToolApprovalResponseContent(
    String requestId,
    bool approved,
    ToolCallContent toolCall,
  ) : approved = approved,
      toolCall = Throw.ifNull(toolCall);

  /// Gets a value indicating whether the tool call was approved for execution.
  final bool approved;

  /// Gets the tool call that was subject to approval.
  final ToolCallContent toolCall;

  /// Gets or sets the optional reason for the approval or rejection.
  String? reason;
}
