import '../abstractions/contents/ai_content.dart';
import '../abstractions/contents/text_content.dart';

/// Extension methods for [ChatResponse].
extension ChatResponseExtensions on ChatResponse {
  /// Renders the supplied `response` to a `string`. The returned `string` can
  /// used as part of constructing an evaluation prompt to evaluate a
  /// conversation that includes the supplied `response`.
  ///
  /// Remarks: This function only considers the [Text] and ignores any
  /// [AIContent]s (present within the [Contents] of the [Messages]) that are
  /// not [TextContent]s. Any [Messages] that contain no [TextContent]s will be
  /// skipped and will not be rendered. If none of the [Messages] include any
  /// [TextContent]s then this function will return an empty string. The
  /// rendered [Messages] are each prefixed with the [Role] and [AuthorName] (if
  /// available) in the returned string. The rendered [Messages]s are also
  /// always separated by new line characters in the returned string.
  ///
  /// Returns: A `string` containing the rendered `response`.
  ///
  /// [response] The [ChatResponse] that is to be rendered.
  String renderText() {
    _ = Throw.ifNull(response);
    return response.messages.renderText();
  }
}
