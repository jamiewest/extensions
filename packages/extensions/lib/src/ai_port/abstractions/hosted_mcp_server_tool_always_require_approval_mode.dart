import 'hosted_mcp_server_tool_approval_mode.dart';

/// Indicates that approval is always required for tool calls to a hosted MCP
/// server.
///
/// Remarks: Use [AlwaysRequire] to get an instance of
/// [HostedMcpServerToolAlwaysRequireApprovalMode].
class HostedMcpServerToolAlwaysRequireApprovalMode
    extends HostedMcpServerToolApprovalMode {
  /// Initializes a new instance of the
  /// [HostedMcpServerToolAlwaysRequireApprovalMode] class.
  ///
  /// Remarks: Use [AlwaysRequire] to get an instance of
  /// [HostedMcpServerToolAlwaysRequireApprovalMode].
  const HostedMcpServerToolAlwaysRequireApprovalMode();

  @override
  bool equals(Object? obj) {
    return obj is HostedMcpServerToolAlwaysRequireApprovalMode;
  }

  @override
  int getHashCode() {
    return typeof(HostedMcpServerToolAlwaysRequireApprovalMode).getHashCode();
  }
}
