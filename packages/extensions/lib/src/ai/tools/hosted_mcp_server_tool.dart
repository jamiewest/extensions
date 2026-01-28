import 'ai_tool.dart';

/// Approval mode for hosted MCP server tools.
///
/// This is an experimental feature.
sealed class HostedMcpServerToolApprovalMode {
  const HostedMcpServerToolApprovalMode._();

  /// Always require approval.
  static const HostedMcpServerToolAlwaysRequireApprovalMode alwaysRequire =
      HostedMcpServerToolAlwaysRequireApprovalMode();

  /// Never require approval.
  static const HostedMcpServerToolNeverRequireApprovalMode neverRequire =
      HostedMcpServerToolNeverRequireApprovalMode();

  /// Require approval for specific tools.
  static HostedMcpServerToolRequireSpecificApprovalMode requireSpecific({
    List<String>? allowedTools,
    List<String>? deniedTools,
  }) =>
      HostedMcpServerToolRequireSpecificApprovalMode(
        allowedTools: allowedTools,
        deniedTools: deniedTools,
      );
}

/// Always require approval for MCP server tool calls.
///
/// This is an experimental feature.
final class HostedMcpServerToolAlwaysRequireApprovalMode
    extends HostedMcpServerToolApprovalMode {
  const HostedMcpServerToolAlwaysRequireApprovalMode() : super._();
}

/// Never require approval for MCP server tool calls.
///
/// This is an experimental feature.
final class HostedMcpServerToolNeverRequireApprovalMode
    extends HostedMcpServerToolApprovalMode {
  const HostedMcpServerToolNeverRequireApprovalMode() : super._();
}

/// Require approval for specific MCP server tool calls.
///
/// This is an experimental feature.
final class HostedMcpServerToolRequireSpecificApprovalMode
    extends HostedMcpServerToolApprovalMode {
  const HostedMcpServerToolRequireSpecificApprovalMode({
    this.allowedTools,
    this.deniedTools,
  }) : super._();

  /// Tools that are allowed without approval.
  final List<String>? allowedTools;

  /// Tools that are denied.
  final List<String>? deniedTools;
}

/// A tool representing a hosted MCP server.
///
/// This is an experimental feature.
class HostedMcpServerTool extends AITool {
  /// Creates a new [HostedMcpServerTool].
  HostedMcpServerTool({
    required this.serverName,
    this.serverAddress,
    this.authorizationToken,
    this.serverDescription,
    this.allowedTools,
    this.approvalMode,
    this.headers,
  }) : super(name: 'mcp', description: 'MCP server');

  /// The name of the MCP server.
  final String serverName;

  /// The address of the MCP server.
  final Uri? serverAddress;

  /// The authorization token.
  final String? authorizationToken;

  /// A description of the MCP server.
  final String? serverDescription;

  /// The list of allowed tool names.
  final List<String>? allowedTools;

  /// The approval mode for tool calls.
  final HostedMcpServerToolApprovalMode? approvalMode;

  /// Additional HTTP headers.
  final Map<String, String>? headers;
}
