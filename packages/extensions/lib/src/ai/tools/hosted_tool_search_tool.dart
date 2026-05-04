import 'package:extensions/annotations.dart';

import 'ai_tool.dart';

/// A marker tool that enables on-demand tool discovery from a hosted service.
///
/// When included in the tools list, deferred tools are not placed into the
/// model's context upfront. Instead, the model invokes tool search to surface
/// relevant tools on demand, reducing token consumption for tools the model
/// does not need.
///
/// By default all deferrable tools are treated as deferred. Use [deferredTools]
/// to restrict deferred loading to a specific subset.
///
/// This is an experimental feature.
@Source(
  name: 'HostedToolSearchTool.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Tools/',
)
class HostedToolSearchTool extends AITool {
  /// Creates a new [HostedToolSearchTool].
  HostedToolSearchTool({
    this.deferredTools,
    this.namespace,
    this.namespaceDescription,
  }) : super(name: 'tool_search');

  /// Tool names for which deferred loading is enabled.
  ///
  /// `null` means all deferrable tools are deferred.
  List<String>? deferredTools;

  /// Namespace name under which deferred tools are grouped.
  ///
  /// When non-null, deferred tools are wrapped inside a namespace container.
  String? namespace;

  /// Description for the namespace when [namespace] is specified.
  String? namespaceDescription;
}
