import 'ai_content.dart';

/// Represents a reference to a vector store hosted by the AI service.
class HostedVectorStoreContent extends AIContent {
  /// Creates a new [HostedVectorStoreContent].
  HostedVectorStoreContent({
    required this.vectorStoreId,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// The identifier of the hosted vector store.
  final String vectorStoreId;

  @override
  String toString() => vectorStoreId;
}
