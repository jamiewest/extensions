import 'ai_content.dart';
import 'input_request_content.dart';

/// Represents the response to an [InputRequestContent].
class InputResponseContent extends AContent {
  /// Initializes a new instance of the [InputResponseContent] class.
  ///
  /// [requestId] The unique identifier that correlates this response with its
  /// corresponding request.
  const InputResponseContent(String requestId)
    : requestId = Throw.ifNullOrWhitespace(requestId);

  /// Gets the unique identifier that correlates this response with its
  /// corresponding [InputRequestContent].
  final String requestId;
}
