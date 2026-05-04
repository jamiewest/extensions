import 'ai_content.dart';
import 'data_uri_parser.dart';
import 'uri_content.dart';

/// Represents binary content with an associated media type (also known as
/// MIME type).
///
/// Remarks: The content represents in-memory data. For references to data at
/// a remote URI, use [UriContent] instead. [Uri] always returns a valid URI
/// string, even if the instance was constructed from a [ReadOnlyMemory]. In
/// that case, a data URI will be constructed and returned.
class DataContent extends AContent {
  /// Initializes a new instance of the [DataContent] class.
  ///
  /// [uri] The data URI containing the content.
  ///
  /// [mediaType] The media type (also known as MIME type) represented by the
  /// content. If not provided, it must be provided as part of the `uri`.
  DataContent({Uri? uri = null, String? mediaType = null, ReadOnlyMemory<int>? data = null, });

  /// Parsed data URI information.
  final DataUri? _dataUri;

  /// The string-based representation of the URI, including any data in the
  /// instance.
  String? _uri;

  /// The data, lazily initialized if the data is provided in a data URI.
  ReadOnlyMemory<int>? _data;

  /// Gets the data URI for this [DataContent].
  ///
  /// Remarks: The returned URI is always a valid data URI string, even if the
  /// instance was constructed from a [ReadOnlyMemory] or from a [Uri].
  final String uri;

  /// Gets the media type (also known as MIME type) of the content.
  ///
  /// Remarks: If the media type was explicitly specified, this property returns
  /// that value. If the media type was not explicitly specified, but a data URI
  /// was supplied and that data URI contained a non-default media type, that
  /// media type is returned.
  final String mediaType;

  /// Gets or sets an optional name associated with the data.
  ///
  /// Remarks: A service might use this name as part of citations or to help
  /// infer the type of data being represented based on a file extension. When
  /// using [CancellationToken)], if the path provided is a directory, [Name]
  /// may be used as part of the output file's name.
  String? name;

  /// Gets the data represented by this instance.
  ///
  /// Remarks: If the instance was constructed from a [ReadOnlyMemory], this
  /// property returns that data. If the instance was constructed from a data
  /// URI, this property the data contained within the data URI. If, however,
  /// the instance was constructed from another form of URI, one that simply
  /// references where the data can be found but doesn't actually contain the
  /// data, this property returns `null`; no attempt is made to retrieve the
  /// data from that URI.
  final ReadOnlyMemory<int> data;

  /// Gets the data represented by this instance as a Base64 character sequence.
  ///
  /// Returns: The base64 representation of the data.
  final ReadOnlyMemory<char> base64Data;

  /// Gets a string representing this instance to display in the debugger.
  final String debuggerDisplay;

  /// Loads a [DataContent] from a file path asynchronously.
  ///
  /// Returns: A [DataContent] containing the file data with the inferred or
  /// specified media type and name.
  ///
  /// [path] The absolute or relative file path to load the data from. Relative
  /// file paths are relative to the current working directory.
  ///
  /// [mediaType] The media type (also known as MIME type) represented by the
  /// content. If not provided, it will be inferred from the file extension. If
  /// it cannot be inferred, "application/octet-stream" is used.
  ///
  /// [cancellationToken] The [CancellationToken] to monitor for cancellation
  /// requests.
  static Future<DataContent> loadFrom(
    String? mediaType,
    CancellationToken cancellationToken,
    {String? path, Stream? stream, },
  ) async  {
    _ = Throw.ifNullOrEmpty(path);
    var fileStream = new(path, FileMode.open, FileAccess.read, FileShare.read, 1, useAsync: true);
    return await loadFromAsync(fileStream, mediaType, cancellationToken).configureAwait(false);
  }

  /// Saves the data content to a file asynchronously.
  ///
  /// Returns: The actual path where the data was saved, which may include an
  /// inferred file name and/or extension.
  ///
  /// [path] The absolute or relative file path to save the data to. If the path
  /// is to an existing directory, the file name will be inferred from the
  /// [Name] property, or a random name will be used with an extension based on
  /// the [MediaType], if possible.
  ///
  /// [cancellationToken] The [CancellationToken] to monitor for cancellation
  /// requests.
  Future<String> saveTo(String path, {CancellationToken? cancellationToken, }) async  {
    _ = Throw.ifNull(path);
    if (path.length == 0 || Directory.exists(path)) {
      var name = null;
      if (name != null) {
        name = Path.getFileName(name);
      }
      if (string.isNullOrEmpty(name)) {
        name = '${Guid.newGuid():N}${MediaTypeMap.getExtension(mediaType)}';
      }
      path = path.length == 0 ? name! : Path.combine(path, name);
    }
    var fileStream = new(
      path,
      FileMode.createNew,
      FileAccess.write,
      FileShare.none,
      1,
      useAsync: true,
    );
    ArraySegment<byte> array;
    if (!MemoryMarshal.tryGetArray(data)) {
      array = new(data.toArray());
    }
    await fileStream.writeAsync(
      array.array,
      array.offset,
      array.count,
      cancellationToken,
    ) .configureAwait(false);
    return fileStream.name;
  }

  /// Determines whether the [MediaType]'s top-level type matches the specified
  /// `topLevelType`.
  ///
  /// Remarks: A media type is primarily composed of two parts, a "type" and a
  /// "subtype", separated by a slash ("/"). The type portion is also referred
  /// to as the "top-level type"; for example, "image/png" has a top-level type
  /// of "image". [String)] compares the specified `topLevelType` against the
  /// type portion of [MediaType].
  ///
  /// Returns: `true` if the type portion of [MediaType] matches the specified
  /// value; otherwise, false.
  ///
  /// [topLevelType] The type to compare against [MediaType].
  bool hasTopLevelMediaType(String topLevelType) {
    return DataUriParser.hasTopLevelMediaType(mediaType, topLevelType);
  }
}
