import 'ai_content.dart';

/// Represents a reference to a file hosted by the AI service.
class HostedFileContent extends AIContent {
  /// Creates a new [HostedFileContent].
  HostedFileContent({
    required this.fileId,
    this.mediaType,
    this.name,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// The identifier of the hosted file.
  final String fileId;

  /// The MIME type of the file.
  final String? mediaType;

  /// The name of the file.
  final String? name;

  /// Returns whether the file has the given top-level media type.
  bool hasTopLevelMediaType(String mediaType) {
    if (this.mediaType == null) return false;
    final topLevel = this.mediaType!.split('/').first;
    return topLevel == mediaType;
  }

  @override
  String toString() => fileId;
}
