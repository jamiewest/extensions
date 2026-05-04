import 'ai_tool.dart';

/// Represents a hosted tool that can be specified to an AI service to enable
/// it to perform web searches.
///
/// Remarks: This tool does not itself implement web searches. It is a marker
/// that can be used to inform a service that the service is allowed to
/// perform web searches if the service is capable of doing so.
class HostedWebSearchTool extends ATool {
  /// Initializes a new instance of the [HostedWebSearchTool] class.
  ///
  /// [additionalProperties] Any additional properties associated with the tool.
  HostedWebSearchTool(Map<String, Object?>? additionalProperties)
    : additionalProperties = additionalProperties,
      _additionalProperties = additionalProperties;

  /// Any additional properties associated with the tool.
  Map<String, Object?>? _additionalProperties;

  String get name {
    return "web_search";
  }

  Map<String, Object?> get additionalProperties {
    return _additionalProperties ?? base.additionalProperties;
  }
}
