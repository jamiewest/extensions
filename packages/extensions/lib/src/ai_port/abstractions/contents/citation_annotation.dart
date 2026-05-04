import 'ai_annotation.dart';

/// Represents an annotation that links content to source references, such as
/// documents, URLs, files, or tool outputs.
class CitationAnnotation extends AAnnotation {
  /// Initializes a new instance of the [CitationAnnotation] class.
  const CitationAnnotation();

  /// Gets or sets the title or name of the source.
  ///
  /// Remarks: This value could be the title of a document, the title from a web
  /// page, the name of a file, or similarly descriptive text.
  String? title;

  /// Gets or sets a URI from which the source material was retrieved.
  Uri? url;

  /// Gets or sets a source identifier associated with the annotation.
  ///
  /// Remarks: This is a provider-specific identifier that can be used to
  /// reference the source material by an ID. This might be a document ID, a
  /// file ID, or some other identifier for the source material that can be used
  /// to uniquely identify it with the provider.
  String? fileId;

  /// Gets or sets the name of any tool involved in the production of the
  /// associated content.
  ///
  /// Remarks: This might be a function name, such as one from [Name], or the
  /// name of a built-in tool from the provider, such as "code_interpreter" or
  /// "file_search".
  String? toolName;

  /// Gets or sets a snippet or excerpt from the source that was cited.
  String? snippet;
}
