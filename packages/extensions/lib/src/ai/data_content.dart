import 'dart:typed_data';

import 'ai_content.dart';

/// Represents binary data content, such as an image or audio.
class DataContent extends AIContent {
  /// Creates a [DataContent] from raw bytes and a media type.
  DataContent(this.data, {required this.mediaType, this.name});

  /// Creates a [DataContent] from a data URI string.
  DataContent.fromUri(String uri, {this.name})
      : data = null,
        mediaType = null,
        _uri = uri;

  /// The raw byte data, if available.
  final Uint8List? data;

  /// The MIME type of the data (e.g. "image/png").
  final String? mediaType;

  /// An optional name or identifier for the data.
  String? name;

  String? _uri;

  /// The URI representation (data URI or original URI).
  String? get uri => _uri;

  /// Returns `true` if the [mediaType] has the given top-level type.
  bool hasTopLevelMediaType(String topLevelType) =>
      mediaType?.startsWith('$topLevelType/') ?? false;
}
