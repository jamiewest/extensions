import '../hosted_mcp_server_tool_approval_mode.dart';
import 'ai_tool.dart';

/// Represents a hosted MCP server tool that can be specified to an AI
/// service.
class HostedMcpServerTool extends ATool {
  /// Initializes a new instance of the [HostedMcpServerTool] class.
  ///
  /// [serverName] The name of the remote MCP server.
  ///
  /// [serverAddress] The address of the remote MCP server. This may be a URL,
  /// or in the case of a service providing built-in MCP servers with known
  /// names, it can be such a name.
  HostedMcpServerTool(
    String serverName, {
    String? serverAddress = null,
    Map<String, Object?>? additionalProperties = null,
  }) : serverName = Throw.ifNullOrWhitespace(serverName),
       serverAddress = Throw.ifNullOrWhitespace(serverAddress);

  /// Any additional properties associated with the tool.
  Map<String, Object?>? _additionalProperties;

  /// Gets the name of the remote MCP server that is used to identify it.
  final String serverName;

  /// Gets the address of the remote MCP server. This may be a URL, or in the
  /// case of a service providing built-in MCP servers with known names, it can
  /// be such a name.
  final String serverAddress;

  /// Gets or sets the description of the remote MCP server, used to provide
  /// more context to the AI service.
  String? serverDescription;

  /// Gets or sets the list of tools allowed to be used by the AI service.
  ///
  /// Remarks: The default value is `null`, which allows any tool to be used.
  List<String>? allowedTools;

  /// Gets or sets the approval mode that indicates when the AI service should
  /// require user approval for tool calls to the remote MCP server.
  ///
  /// Remarks: You can set this property to [AlwaysRequire] to require approval
  /// for all tool calls, or to [NeverRequire] to never require approval. The
  /// default value is `null`, which some providers might treat the same as
  /// [AlwaysRequire]. The underlying provider is not guaranteed to support or
  /// honor the approval mode.
  HostedMcpServerToolApprovalMode? approvalMode;

  /// Gets or sets a mutable dictionary of HTTP headers to include when calling
  /// the remote MCP server.
  ///
  /// Remarks: The underlying provider is not guaranteed to support or honor the
  /// headers. This property is useful for specifying the authentication header
  /// or other headers required by the MCP server. As HTTP header names are
  /// case-insensitive, callers should use [OrdinalIgnoreCase] comparison when
  /// constructing the dictionary.
  Map<String, String>? headers;

  static String validateUrl(Uri serverAddress) {
    _ = Throw.ifNull(serverAddress);
    if (!serverAddress.isAbsoluteUri) {
      Throw.argumentException(
        nameof(serverAddress),
        "The provided URL is! absolute.",
      );
    }
    return serverAddress.absoluteUri;
  }

  String get name {
    return "mcp";
  }

  Map<String, Object?> get additionalProperties {
    return _additionalProperties ?? base.additionalProperties;
  }
}
