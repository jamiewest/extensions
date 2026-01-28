import 'ai_content.dart';

/// Represents content referenced by a URI.
class UriContent extends AIContent {
  /// Creates a [UriContent] with the given [uri] and [mediaType].
  UriContent(this.uri, {required this.mediaType});

  /// The URI pointing to the content.
  final Uri uri;

  /// The MIME type of the referenced content.
  final String mediaType;

  /// Returns `true` if the [mediaType] has the given top-level type.
  bool hasTopLevelMediaType(String topLevelType) =>
      mediaType.startsWith('$topLevelType/');
}
