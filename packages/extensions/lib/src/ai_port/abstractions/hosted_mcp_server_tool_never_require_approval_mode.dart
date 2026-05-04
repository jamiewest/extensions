import 'hosted_mcp_server_tool_approval_mode.dart';

/// Indicates that approval is never required for tool calls to a hosted MCP
/// server.
///
/// Remarks: Use [NeverRequire] to get an instance of
/// [HostedMcpServerToolNeverRequireApprovalMode].
class HostedMcpServerToolNeverRequireApprovalMode
    extends HostedMcpServerToolApprovalMode {
  /// Initializes a new instance of the
  /// [HostedMcpServerToolNeverRequireApprovalMode] class.
  ///
  /// Remarks: Use [NeverRequire] to get an instance of
  /// [HostedMcpServerToolNeverRequireApprovalMode].
  const HostedMcpServerToolNeverRequireApprovalMode();

  @override
  bool equals(Object? obj) {
    return obj is HostedMcpServerToolNeverRequireApprovalMode;
  }

  @override
  int getHashCode() {
    return typeof(HostedMcpServerToolNeverRequireApprovalMode).getHashCode();
  }
}
