import 'ai_content.dart';
import 'data_content.dart';
import 'data_uri_parser.dart';

/// Represents a URL, typically to hosted content such as an image, audio, or
/// video.
///
/// Remarks: This class is intended for use with HTTP or HTTPS URIs that
/// reference hosted content. For data URIs, use [DataContent] instead.
class UriContent extends AContent {
  /// Initializes a new instance of the [UriContent] class.
  ///
  /// [uri] The URI to the represented content.
  ///
  /// [mediaType] The media type (also known as MIME type) represented by the
  /// content. If not provided, it will be inferred from the file extension of
  /// the URI. If it cannot be inferred, "application/octet-stream" is used.
  UriContent(String? mediaType, {String? uri = null}) : mediaType = mediaType;

  /// The URI represented.
  Uri _uri;

  /// The MIME type of the data at the referenced URI.
  String _mediaType;

  /// Gets or sets the [Uri] for this content.
  Uri uri;

  /// Gets or sets the media type (also known as MIME type) for this content.
  String mediaType;

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

  /// Gets a string representing this instance to display in the debugger.
  String get debuggerDisplay {
    return 'uri = ${_uri}';
  }

  /// Infers the media type from the URI's file extension.
  static String inferMediaType(Uri uri) {
    String path;
    if (uri.isAbsoluteUri) {
      path = uri.absolutePath;
    } else {
      path = uri.originalString;
      var i = path.asSpan().indexOfAny('?', '#');
      if (i >= 0) {
        path = path.substring(0, i);
      }
    }
    return MediaTypeMap.getMediaType(path) ?? DefaultMediaType;
  }
}
