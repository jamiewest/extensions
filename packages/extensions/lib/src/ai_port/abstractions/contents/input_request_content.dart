import 'ai_content.dart';
import 'input_response_content.dart';

/// Represents a request for input from the user or application.
class InputRequestContent extends AContent {
  /// Initializes a new instance of the [InputRequestContent] class.
  ///
  /// [requestId] The unique identifier that correlates this request with its
  /// corresponding response.
  const InputRequestContent(String requestId)
    : requestId = Throw.ifNullOrWhitespace(requestId);

  /// Gets the unique identifier that correlates this request with its
  /// corresponding [InputResponseContent].
  final String requestId;
}
