import 'dart:typed_data';

import 'ai_content.dart';

/// Represents binary data content, such as an image or audio.
class DataContent extends AIContent {
  /// Creates a [DataContent] from raw bytes and a media type.
  DataContent(this.data, {required this.mediaType, this.name});

  /// Creates a [DataContent] from a URI string.
  ///
  /// A `data:` URI is parsed (the upstream `DataUriParser` maps to the
  /// platform's [UriData]) so that [data] and [mediaType] are populated
  /// from its contents. Any other URI is stored as-is with no data.
  ///
  /// Throws [FormatException] when a `data:` URI is malformed.
  factory DataContent.fromUri(String uri, {String? name}) {
    if (uri.startsWith('data:')) {
      final parsed = UriData.parse(uri);
      final mimeType = parsed.mimeType;
      return DataContent(
        Uint8List.fromList(parsed.contentAsBytes()),
        mediaType: mimeType.isEmpty ? null : mimeType,
        name: name,
      ).._uri = uri;
    }
    return DataContent(null, mediaType: null, name: name).._uri = uri;
  }

  /// The raw byte data, if available.
  final Uint8List? data;

  /// The MIME type of the data (e.g. "image/png").
  final String? mediaType;

  /// An optional name or identifier for the data.
  String? name;

  String? _uri;

  /// The URI representation.
  ///
  /// Returns the original URI when this content was created from one;
  /// otherwise a data URI synthesized from [data] and [mediaType], or
  /// `null` when no data is present.
  String? get uri {
    if (_uri != null) {
      return _uri;
    }
    final bytes = data;
    if (bytes == null) {
      return null;
    }
    return UriData.fromBytes(
      bytes,
      mimeType: mediaType ?? 'application/octet-stream',
    ).toString();
  }

  /// Returns `true` if the [mediaType] has the given top-level type.
  bool hasTopLevelMediaType(String topLevelType) =>
      mediaType?.startsWith('$topLevelType/') ?? false;
}
