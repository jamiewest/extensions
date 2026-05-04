import 'ai_annotation.dart';

/// Represents content used by AI services.
class AContent {
  /// Initializes a new instance of the [AIContent] class.
  const AContent();

  /// Gets or sets a list of annotations on this content.
  List<AAnnotation>? annotations;

  /// Gets or sets the raw representation of the content from an underlying
  /// implementation.
  ///
  /// Remarks: If an [AIContent] is created to represent some underlying object
  /// from another object model, this property can be used to store that
  /// original object. This can be useful for debugging or for enabling a
  /// consumer to access the underlying object model, if needed.
  Object? rawRepresentation;

  /// Gets or sets additional properties for the content.
  AdditionalPropertiesDictionary? additionalProperties;
}
