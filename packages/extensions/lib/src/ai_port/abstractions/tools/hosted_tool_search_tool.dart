import 'ai_tool.dart';

/// Represents a hosted tool that can be specified to an AI service to enable
/// it to search for and selectively load tool definitions on demand.
///
/// Remarks: This tool does not itself implement tool search. It is a marker
/// that can be used to inform a service that tool search should be enabled.
/// When included, deferred tools are not placed into the model's context
/// upfront; instead, the model invokes tool search to surface relevant tools
/// on demand, reducing the input tokens consumed by tool definitions the
/// model doesn't need. By default, when a [HostedToolSearchTool] is present
/// in the tools list, all other deferrable tools are treated as having
/// deferred loading enabled. Use [DeferredTools] to control which tools have
/// deferred loading on a per-tool basis.
class HostedToolSearchTool extends ATool {
  /// Initializes a new instance of the [HostedToolSearchTool] class.
  ///
  /// [additionalProperties] Any additional properties associated with the tool.
  HostedToolSearchTool(Map<String, Object?>? additionalProperties)
    : additionalProperties = additionalProperties,
      _additionalProperties = additionalProperties;

  /// Any additional properties associated with the tool.
  Map<String, Object?>? _additionalProperties;

  /// Gets or sets the list of tool names for which deferred loading should be
  /// enabled.
  ///
  /// Remarks: The default value is `null`, which enables deferred loading for
  /// all deferrable tools in the tools list. When non-null, only deferrable
  /// tools whose names appear in this list will have deferred loading enabled.
  List<String>? deferredTools;

  /// Gets or sets the namespace name under which deferred tools should be
  /// grouped.
  ///
  /// Remarks: When non-null, all deferred tools are wrapped inside a
  /// `{"type":"namespace","name":"..."}` container. Non-deferred tools remain
  /// as top-level tools. When `null` (the default), deferred tools are sent as
  /// top-level tools with `defer_loading` set individually. Use
  /// [NamespaceDescription] to supply a description for the namespace.
  String? namespace;

  /// Gets or sets the description for the namespace produced when [Namespace]
  /// is specified.
  ///
  /// Remarks: Setting this property alone does not create a namespace. When
  /// `null`, no description is emitted on the namespace. The underlying
  /// provider may require a description when a namespace is supplied.
  String? namespaceDescription;

  String get name {
    return "tool_search";
  }

  Map<String, Object?> get additionalProperties {
    return _additionalProperties ?? base.additionalProperties;
  }
}
