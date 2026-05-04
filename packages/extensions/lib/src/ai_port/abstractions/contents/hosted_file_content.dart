import 'ai_content.dart';
import 'data_content.dart';
import 'data_uri_parser.dart';

/// Represents a file that is hosted by the AI service.
///
/// Remarks: Unlike [DataContent] which contains the data for a file or blob,
/// this class represents a file that is hosted by the AI service and
/// referenced by an identifier. Such identifiers are specific to the
/// provider.
class HostedFileContent extends AContent {
  /// Initializes a new instance of the [HostedFileContent] class.
  ///
  /// [fileId] The ID of the hosted file.
  const HostedFileContent(String fileId)
    : fileId = Throw.ifNullOrWhitespace(fileId);

  /// Gets or sets the ID of the hosted file.
  String fileId;

  /// Gets or sets an optional media type (also known as MIME type) associated
  /// with the file.
  String? mediaType;

  /// Gets or sets an optional name associated with the file.
  String? name;

  /// Gets or sets the size of the file in bytes.
  long? sizeInBytes;

  long? sizeInBytesCore;

  /// Gets or sets when the file was created.
  DateTime? createdAt;

  DateTime? createdAtCore;

  /// Gets or sets the purpose for which the file was uploaded.
  ///
  /// Remarks: Common values include "assistants", "fine-tune", "batch", or
  /// "vision", but the specific values supported depend on the provider.
  String? purpose;

  String? purposeCore;

  /// Gets or sets the scope (e.g. container ID) in which the file resides.
  ///
  /// Remarks: When set, file operations such as downloading will target this
  /// scope. For example, files created by a code interpreter tool are stored in
  /// a container, and the container ID is the scope needed to access them.
  String? scope;

  String? scopeCore;

  /// Gets a string representing this instance to display in the debugger.
  final String debuggerDisplay;

  /// Determines whether the [MediaType]'s top-level type matches the specified
  /// `topLevelType`.
  ///
  /// Remarks: A media type is primarily composed of two parts, a "type" and a
  /// "subtype", separated by a slash ("/"). The type portion is also referred
  /// to as the "top-level type"; for example, "image/png" has a top-level type
  /// of "image". [String)] compares the specified `topLevelType` against the
  /// type portion of [MediaType]. If [MediaType] is `null`, this method returns
  /// `false`.
  ///
  /// Returns: `true` if the type portion of [MediaType] matches the specified
  /// value; otherwise, false.
  ///
  /// [topLevelType] The type to compare against [MediaType].
  bool hasTopLevelMediaType(String topLevelType) {
    return mediaType != null &&
        DataUriParser.hasTopLevelMediaType(mediaType, topLevelType);
  }
}
