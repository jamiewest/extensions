import 'dart:typed_data';

import 'additional_properties_dictionary.dart';

/// Represents a token that can be used to resume an interrupted response.
///
/// This is an experimental feature.
class ResponseContinuationToken {
  /// Creates a [ResponseContinuationToken] from raw bytes.
  ResponseContinuationToken.fromBytes(this.data);

  /// The raw token data.
  final Uint8List data;

  /// Additional properties.
  AdditionalPropertiesDictionary? additionalProperties;

  /// Converts this token to its byte representation.
  Uint8List toBytes() => data;
}
