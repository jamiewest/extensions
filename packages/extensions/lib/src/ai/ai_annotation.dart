import 'additional_properties_dictionary.dart';

/// Base class for annotations on AI content.
abstract class AIAnnotation {
  /// Creates a new [AIAnnotation].
  AIAnnotation({
    this.annotatedRegions,
    this.rawRepresentation,
    this.additionalProperties,
  });

  /// The regions of content this annotation applies to.
  List<AnnotatedRegion>? annotatedRegions;

  /// The underlying implementation-specific representation.
  Object? rawRepresentation;

  /// Additional properties.
  AdditionalPropertiesDictionary? additionalProperties;
}

/// Base class for annotated regions.
abstract class AnnotatedRegion {
  /// Creates a new [AnnotatedRegion].
  const AnnotatedRegion();
}

/// An annotated region defined by character span indices.
class TextSpanAnnotatedRegion extends AnnotatedRegion {
  /// Creates a new [TextSpanAnnotatedRegion].
  const TextSpanAnnotatedRegion({this.startIndex, this.endIndex});

  /// The start character index (inclusive).
  final int? startIndex;

  /// The end character index (exclusive).
  final int? endIndex;
}

/// An annotation citing a source.
class CitationAnnotation extends AIAnnotation {
  /// Creates a new [CitationAnnotation].
  CitationAnnotation({
    this.title,
    this.url,
    this.fileId,
    this.toolName,
    this.snippet,
    super.annotatedRegions,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// The title of the cited source.
  String? title;

  /// The URL of the cited source.
  Uri? url;

  /// A provider-specific file identifier.
  String? fileId;

  /// The name of the tool that produced the cited content.
  String? toolName;

  /// An excerpt from the source.
  String? snippet;
}
