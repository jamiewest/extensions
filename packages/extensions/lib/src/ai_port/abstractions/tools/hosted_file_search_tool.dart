import '../contents/ai_content.dart';
import '../contents/data_content.dart';
import '../contents/hosted_file_content.dart';
import '../contents/hosted_vector_store_content.dart';
import 'ai_tool.dart';

/// Represents a hosted tool that can be specified to an AI service to enable
/// it to perform file search operations.
///
/// Remarks: This tool is designed to facilitate file search functionality
/// within AI services. It allows the service to search for relevant content
/// based on the provided inputs and constraints, such as the maximum number
/// of results.
class HostedFileSearchTool extends ATool {
  /// Initializes a new instance of the [HostedFileSearchTool] class.
  ///
  /// [additionalProperties] Any additional properties associated with the tool.
  HostedFileSearchTool(Map<String, Object?>? additionalProperties)
    : additionalProperties = additionalProperties,
      _additionalProperties = additionalProperties;

  /// Any additional properties associated with the tool.
  Map<String, Object?>? _additionalProperties;

  /// Gets or sets a collection of [AIContent] to be used as input to the file
  /// search tool.
  ///
  /// Remarks: If no explicit inputs are provided, the service determines what
  /// inputs should be searched. Different services support different kinds of
  /// inputs, for example, some might respect [HostedFileContent] using
  /// provider-specific file IDs, others might support binary data uploaded as
  /// part of the request in [DataContent], and others might support content in
  /// a hosted vector store and represented by a [HostedVectorStoreContent].
  List<AContent>? inputs;

  /// Gets or sets a requested bound on the number of matches the tool should
  /// produce.
  int? maximumResultCount;

  String get name {
    return "file_search";
  }

  Map<String, Object?> get additionalProperties {
    return _additionalProperties ?? base.additionalProperties;
  }
}
