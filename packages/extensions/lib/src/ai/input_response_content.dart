import 'ai_content.dart';

/// Represents the response to an [InputRequestContent].
///
/// The [requestId] correlates this response with its originating request.
class InputResponseContent extends AIContent {
  /// Creates a new [InputResponseContent].
  InputResponseContent({
    required this.requestId,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// Unique identifier correlating this response with its request.
  final String requestId;
}
