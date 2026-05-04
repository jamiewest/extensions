import 'ai_content.dart';
import 'text_span_annotated_region.dart';

/// Describes the portion of an associated [AIContent] to which an annotation
/// applies.
///
/// Remarks: Details about the region is provided by derived types based on
/// how the region is described. For example, starting and ending indices into
/// text content are provided by [TextSpanAnnotatedRegion].
class AnnotatedRegion {
  /// Initializes a new instance of the [AnnotatedRegion] class.
  const AnnotatedRegion();
}
