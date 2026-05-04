import 'ai_content.dart';
import 'hosted_file_content.dart';

/// Represents a vector store that is hosted by the AI service.
///
/// Remarks: Unlike [HostedFileContent] which represents a specific file that
/// is hosted by the AI service, [HostedVectorStoreContent] represents a
/// vector store that can contain multiple files, indexed for searching.
class HostedVectorStoreContent extends AContent {
  /// Initializes a new instance of the [HostedVectorStoreContent] class.
  ///
  /// [vectorStoreId] The ID of the hosted file store.
  HostedVectorStoreContent(String vectorStoreId)
    : vectorStoreId = vectorStoreId,
      _vectorStoreId = Throw.ifNullOrWhitespace(vectorStoreId);

  String _vectorStoreId;

  /// Gets or sets the ID of the hosted vector store.
  String vectorStoreId;
}
