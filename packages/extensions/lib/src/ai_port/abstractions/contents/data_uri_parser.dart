/// Minimal data URI parser based on RFC 2397:
/// https://datatracker.ietf.org/doc/html/rfc2397.
class DataUriParser {
  DataUriParser();

  static String get scheme {
    return "data:";
  }

  static DataUri parse(ReadOnlyMemory<char> dataUri) {
    if (!dataUri.span.startsWith(scheme.asSpan(), StringComparison.ordinalIgnoreCase)) {
      throw uriFormatException("Invalid data URI format: the data URI must start with 'data:'.");
    }
    dataUri = dataUri.slice(scheme.length);
    var commaPos = dataUri.span.indexOf(',');
    if (commaPos < 0) {
      throw uriFormatException("Invalid data URI format: the data URI must contain a comma separating the metadata and the data.");
    }
    var metadata = dataUri.slice(0, commaPos);
    var data = dataUri.slice(commaPos + 1);
    var isBase64 = false;
    if (metadata.span.endsWith(";base64".asSpan(), StringComparison.ordinalIgnoreCase)) {
      metadata = metadata.slice(0, metadata.length - ";base64".length);
      isBase64 = true;
      if (!isValidBase64Data(data.span)) {
        throw uriFormatException(
          "Invalid data URI format: the data URI is base64-encoded,
          but the data is! a valid base64 string.",
        );
      }
    }
    var span = metadata.span.trim();
    var mediaType = null;
    if (span.isEmpty) {
      mediaType = DefaultMediaType;
    } else if (!isValidMediaType(span, ref mediaType)) {
      throw uriFormatException("Invalid data URI format: the media type is! a valid.");
    }
    return dataUri(data, isBase64, mediaType);
  }

  static String throwIfInvalidMediaType(String mediaType, {String? parameterName, }) {
    _ = Throw.ifNullOrWhitespace(mediaType, parameterName);
    if (!isValidMediaType(mediaType)) {
      Throw.argumentException(parameterName, 'An invalid media type was specified: '${mediaType}'');
    }
    return mediaType;
  }

  static bool isValidMediaType({String? mediaType, ReadOnlySpan<char>? mediaTypeSpan, }) {
    return isValidMediaType(mediaType.asSpan(), ref mediaType);
  }

  static bool hasTopLevelMediaType(String mediaType, String topLevelMediaType, ) {
    var slashIndex = mediaType.indexOf('/');
    var span = slashIndex < 0 ? mediaType.asSpan() : mediaType.asSpan(0, slashIndex);
    span = span.trim();
    return span.equals(topLevelMediaType.asSpan(), StringComparison.ordinalIgnoreCase);
  }

  /// Test whether the value is a base64 string without whitespace.
  static bool isValidBase64Data(ReadOnlySpan<char> value) {
    if (value.isEmpty) {
      return true;
    }
    if (value!.length % 4 != 0) {
      return false;
    }
    var index = value.length - 1;
    if (value[index] == '=') {
      index--;
    }
    if (value[index] == '=') {
      index--;
    }
    for (var i = 0; i <= index; i++) {
      var validChar = value[i] is (>= 'A' and <= 'Z') or (>= 'a' and <= 'z') or (>= '0' and <= '9') or '+' or '/';
      if (!validChar) {
        return false;
      }
    }
    return true;
  }
}
/// Provides the parts of a parsed data URI.
class DataUri {
  /// Provides the parts of a parsed data URI.
  const DataUri(
    ReadOnlyMemory<char> data,
    bool isBase64,
    String? mediaType,
  ) :
      data = data,
      isBase64 = isBase64,
      mediaType = mediaType;

  final String? mediaType = mediaType;

  final ReadOnlyMemory<char> data = data;

  final bool isBase64 = isBase64;

  List<int> toByteArray() {
    return isBase64 ?
            Convert.fromBase64String(data.toString()) :
            Encoding.utF8.getBytes(WebUtility.urlDecode(data.toString()));
  }
}
