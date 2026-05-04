import 'ai_content.dart';
import 'annotated_region.dart';
import 'text_content.dart';

/// Describes a location in the associated [AIContent] based on starting and
/// ending character indices.
///
/// Remarks: This [AnnotatedRegion] typically applies to [TextContent].
class TextSpanAnnotatedRegion extends AnnotatedRegion {
  /// Initializes a new instance of the [TextSpanAnnotatedRegion] class.
  const TextSpanAnnotatedRegion();

  /// Gets or sets the start character index (inclusive) of the annotated span
  /// in the [AIContent].
  int? startIndex;

  /// Gets or sets the end character index (exclusive) of the annotated span in
  /// the [AIContent].
  int? endIndex;
}
