import 'input_request_content.dart';
import 'tool_approval_response_content.dart';
import 'tool_call_content.dart';

/// Represents a request for approval before invoking a tool call.
class ToolApprovalRequestContent extends InputRequestContent {
  /// Initializes a new instance of the [ToolApprovalRequestContent] class.
  ///
  /// [requestId] The unique identifier that correlates this request with its
  /// corresponding response.
  ///
  /// [toolCall] The tool call that requires approval before execution.
  const ToolApprovalRequestContent(String requestId, ToolCallContent toolCall)
    : toolCall = Throw.ifNull(toolCall);

  /// Gets the tool call that requires approval before execution.
  final ToolCallContent toolCall;

  /// Creates a [ToolApprovalResponseContent] indicating whether the tool call
  /// is approved or rejected.
  ///
  /// Returns: The [ToolApprovalResponseContent] correlated with this request.
  ///
  /// [approved] `true` if the tool call is approved; otherwise, `false`.
  ///
  /// [reason] An optional reason for the approval or rejection.
  ToolApprovalResponseContent createResponse(bool approved, {String? reason}) {
    return toolApprovalResponseContent(RequestId, approved, toolCall);
  }
}
