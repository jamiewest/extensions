import 'additional_properties_dictionary.dart';

/// Base class for all AI content types.
abstract class AIContent {
  /// Creates a new [AIContent].
  AIContent({this.rawRepresentation, this.additionalProperties});

  /// The underlying implementation-specific representation of this content.
  Object? rawRepresentation;

  /// Additional properties.
  AdditionalPropertiesDictionary? additionalProperties;
}
