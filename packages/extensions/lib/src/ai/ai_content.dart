import 'additional_properties_dictionary.dart';
import 'ai_annotation.dart';

/// Base class for all AI content types.
abstract class AIContent {
  /// Creates a new [AIContent].
  AIContent({
    this.annotations,
    this.rawRepresentation,
    this.additionalProperties,
  });

  /// Annotations attached to this content by the provider, such as
  /// [CitationAnnotation]s produced by grounding tools like web search.
  List<AIAnnotation>? annotations;

  /// The underlying implementation-specific representation of this content.
  Object? rawRepresentation;

  /// Additional properties.
  AdditionalPropertiesDictionary? additionalProperties;
}
