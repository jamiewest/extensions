import 'hosted_mcp_server_tool_always_require_approval_mode.dart';
import 'hosted_mcp_server_tool_never_require_approval_mode.dart';
import 'hosted_mcp_server_tool_require_specific_approval_mode.dart';

/// Describes how approval is required for tool calls to a hosted MCP server.
///
/// Remarks: The predefined values [AlwaysRequire], and [NeverRequire] are
/// provided to specify handling for all tools. To specify approval behavior
/// for individual tool names, use [String})].
class HostedMcpServerToolApprovalMode {
  const HostedMcpServerToolApprovalMode();

  /// Gets a predefined [HostedMcpServerToolApprovalMode] indicating that all
  /// tool calls to a hosted MCP server always require approval.
  static final HostedMcpServerToolAlwaysRequireApprovalMode alwaysRequire;

  /// Gets a predefined [HostedMcpServerToolApprovalMode] indicating that all
  /// tool calls to a hosted MCP server never require approval.
  static final HostedMcpServerToolNeverRequireApprovalMode neverRequire;

  /// Instantiates a [HostedMcpServerToolApprovalMode] that specifies approval
  /// behavior for individual tool names.
  ///
  /// Returns: An instance of [HostedMcpServerToolRequireSpecificApprovalMode]
  /// for the specified tool names.
  ///
  /// [alwaysRequireApprovalToolNames] The list of tool names that always
  /// require approval.
  ///
  /// [neverRequireApprovalToolNames] The list of tool names that never require
  /// approval.
  static HostedMcpServerToolRequireSpecificApprovalMode requireSpecific(
    List<String>? alwaysRequireApprovalToolNames,
    List<String>? neverRequireApprovalToolNames,
  ) {
    return new(alwaysRequireApprovalToolNames, neverRequireApprovalToolNames);
  }
}
