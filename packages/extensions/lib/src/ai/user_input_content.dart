import 'ai_content.dart';
import 'function_call_content.dart';
import 'mcp_server_content.dart';

/// Abstract base for content requesting user input.
///
/// This is an experimental feature.
abstract class UserInputRequestContent extends AIContent {
  /// Creates a new [UserInputRequestContent].
  UserInputRequestContent({
    required this.id,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// The unique identifier for this input request.
  final String id;
}

/// Abstract base for content responding to a user input request.
///
/// This is an experimental feature.
abstract class UserInputResponseContent extends AIContent {
  /// Creates a new [UserInputResponseContent].
  UserInputResponseContent({
    required this.id,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// The unique identifier matching the corresponding request.
  final String id;
}

/// A request for user approval of a function call.
///
/// This is an experimental feature.
class FunctionApprovalRequestContent extends UserInputRequestContent {
  /// Creates a new [FunctionApprovalRequestContent].
  FunctionApprovalRequestContent({
    required super.id,
    required this.functionCall,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// The function call requiring approval.
  final FunctionCallContent functionCall;

  /// Creates a response to this approval request.
  FunctionApprovalResponseContent createResponse(
    bool approved, [
    String? reason,
  ]) =>
      FunctionApprovalResponseContent(
        id: id,
        approved: approved,
        functionCall: functionCall,
        reason: reason,
      );

  @override
  String toString() => 'FunctionApprovalRequest($id)';
}

/// A user's response to a function approval request.
///
/// This is an experimental feature.
class FunctionApprovalResponseContent extends UserInputResponseContent {
  /// Creates a new [FunctionApprovalResponseContent].
  FunctionApprovalResponseContent({
    required super.id,
    required this.approved,
    required this.functionCall,
    this.reason,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// Whether the function call was approved.
  final bool approved;

  /// The function call that was approved or denied.
  final FunctionCallContent functionCall;

  /// An optional reason for the decision.
  final String? reason;

  @override
  String toString() => 'FunctionApprovalResponse($id, approved: $approved)';
}

/// A request for user approval of an MCP server tool call.
///
/// This is an experimental feature.
class McpServerToolApprovalRequestContent extends UserInputRequestContent {
  /// Creates a new [McpServerToolApprovalRequestContent].
  McpServerToolApprovalRequestContent({
    required super.id,
    required this.toolCall,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// The MCP server tool call requiring approval.
  final McpServerToolCallContent toolCall;

  /// Creates a response to this approval request.
  McpServerToolApprovalResponseContent createResponse(bool approved) =>
      McpServerToolApprovalResponseContent(
        id: id,
        approved: approved,
      );

  @override
  String toString() => 'McpServerToolApprovalRequest($id)';
}

/// A user's response to an MCP server tool approval request.
///
/// This is an experimental feature.
class McpServerToolApprovalResponseContent extends UserInputResponseContent {
  /// Creates a new [McpServerToolApprovalResponseContent].
  McpServerToolApprovalResponseContent({
    required super.id,
    required this.approved,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// Whether the tool call was approved.
  final bool approved;

  @override
  String toString() =>
      'McpServerToolApprovalResponse($id, approved: $approved)';
}
