import 'ai_content.dart';
import 'annotated_region.dart';
import 'text_content.dart';
import 'text_span_annotated_region.dart';

/// Represents an annotation on content.
class AAnnotation {
  /// Initializes a new instance of the [AIAnnotation] class.
  const AAnnotation();

  /// Gets or sets any target regions for the annotation, pointing to where in
  /// the associated [AIContent] this annotation applies.
  ///
  /// Remarks: The most common form of [AnnotatedRegion] is
  /// [TextSpanAnnotatedRegion], which provides starting and ending character
  /// indices for [TextContent].
  List<AnnotatedRegion>? annotatedRegions;

  /// Gets or sets the raw representation of the annotation from an underlying
  /// implementation.
  ///
  /// Remarks: If an [AIAnnotation] is created to represent some underlying
  /// object from another object model, this property can be used to store that
  /// original object. This can be useful for debugging or for enabling a
  /// consumer to access the underlying object model, if needed.
  Object? rawRepresentation;

  /// Gets or sets additional metadata specific to the provider or source type.
  AdditionalPropertiesDictionary? additionalProperties;
}
