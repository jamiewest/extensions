/// Represents a token used to resume, continue, or rehydrate an operation
/// across multiple scenarios/calls, such as resuming a streamed response from
/// a specific point or retrieving the result of a background operation.
/// Subclasses of this class encapsulate all necessary information within the
/// token to facilitate these actions.
class ResponseContinuationToken {
  /// Initializes a new instance of the [ResponseContinuationToken] class.
  ///
  /// [bytes] Bytes to create the token from.
  const ResponseContinuationToken(ReadOnlyMemory<int> bytes) : _bytes = bytes;

  /// Bytes representing this token.
  final ReadOnlyMemory<int> _bytes;

  /// Create a new instance of [ResponseContinuationToken] from the provided
  /// `bytes`.
  ///
  /// Returns: A [ResponseContinuationToken] equivalent to the one from which
  /// the original[ResponseContinuationToken] bytes were obtained.
  ///
  /// [bytes] Bytes representing the [ResponseContinuationToken].
  static ResponseContinuationToken fromBytes(ReadOnlyMemory<int> bytes) {
    return new(bytes);
  }

  /// Gets the bytes representing this [ResponseContinuationToken].
  ///
  /// Returns: Bytes representing the [ResponseContinuationToken].
  ReadOnlyMemory<int> toBytes() {
    return _bytes;
  }
}
/// Provides a [JsonConverter] for serializing [ResponseContinuationToken]
/// instances.
class Converter extends JsonConverter<ResponseContinuationToken> {
  Converter();

  @override
  ResponseContinuationToken read(
    Utf8JsonReader reader,
    Type typeToConvert,
    JsonSerializerOptions options,
  ) {
    return ResponseContinuationToken.fromBytes(reader.getBytesFromBase64());
  }

  @override
  void write(
    Utf8JsonWriter writer,
    ResponseContinuationToken value,
    JsonSerializerOptions options,
  ) {
    _ = Throw.ifNull(writer);
    _ = Throw.ifNull(value);
    writer.writeBase64StringValue(value.toBytes().span);
  }
}
