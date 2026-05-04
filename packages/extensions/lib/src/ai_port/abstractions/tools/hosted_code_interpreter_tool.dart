import '../chat_completion/chat_client.dart';
import '../contents/ai_content.dart';
import '../contents/data_content.dart';
import '../contents/hosted_file_content.dart';
import 'ai_tool.dart';

/// Represents a hosted tool that can be specified to an AI service to enable
/// it to execute code it generates.
///
/// Remarks: This tool does not itself implement code interpretation. It is a
/// marker that can be used to inform a service that the service is allowed to
/// execute its generated code if the service is capable of doing so.
class HostedCodeInterpreterTool extends ATool {
  /// Initializes a new instance of the [HostedCodeInterpreterTool] class.
  ///
  /// [additionalProperties] Any additional properties associated with the tool.
  HostedCodeInterpreterTool(Map<String, Object?>? additionalProperties)
    : additionalProperties = additionalProperties,
      _additionalProperties = additionalProperties;

  /// Any additional properties associated with the tool.
  Map<String, Object?>? _additionalProperties;

  /// Gets or sets a collection of [AIContent] to be used as input to the code
  /// interpreter tool.
  ///
  /// Remarks: Services support different varied kinds of inputs. Most support
  /// the IDs of files that are hosted by the service, represented via
  /// [HostedFileContent]. Some also support binary data, represented via
  /// [DataContent]. Unsupported inputs will be ignored by the [ChatClient] to
  /// which the tool is passed.
  List<AContent>? inputs;

  String get name {
    return "code_interpreter";
  }

  Map<String, Object?> get additionalProperties {
    return _additionalProperties ?? base.additionalProperties;
  }
}
