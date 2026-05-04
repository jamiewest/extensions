/// Describes the intended purpose of a specific update during streaming of
/// text to speech updates.
class TextToSpeechResponseUpdateKind {
  /// Initializes a new instance of the [TextToSpeechResponseUpdateKind] struct
  /// with the provided value.
  ///
  /// [value] The value to associate with this [TextToSpeechResponseUpdateKind].
  const TextToSpeechResponseUpdateKind(String value) : value = Throw.ifNullOrWhitespace(value);

  /// Gets when the generated audio speech session is opened.
  static final TextToSpeechResponseUpdateKind sessionOpen = new("sessionopen");

  /// Gets when a non-blocking error occurs during text to speech updates.
  static final TextToSpeechResponseUpdateKind error = new("error");

  /// Gets when the audio update is in progress.
  static final TextToSpeechResponseUpdateKind audioUpdating = new("audioupdating");

  /// Gets when an audio chunk has been fully generated.
  static final TextToSpeechResponseUpdateKind audioUpdated = new("audioupdated");

  /// Gets when the generated audio speech session is closed.
  static final TextToSpeechResponseUpdateKind sessionClose = new("sessionclose");

  /// Gets the value associated with this [TextToSpeechResponseUpdateKind].
  ///
  /// Remarks: The value will be serialized into the "kind" message field of the
  /// text to speech update format.
  final String value;

  /// Returns a value indicating whether two [TextToSpeechResponseUpdateKind]
  /// instances are equivalent, as determined by a case-insensitive comparison
  /// of their values.
  ///
  /// Returns: `true` if left and right are both null or have equivalent values;
  /// otherwise, `false`.
  ///
  /// [left] The first [TextToSpeechResponseUpdateKind] instance to compare.
  ///
  /// [right] The second [TextToSpeechResponseUpdateKind] instance to compare.
  static bool op_Equality(
    TextToSpeechResponseUpdateKind left,
    TextToSpeechResponseUpdateKind right,
  ) {
    // TODO: implement op_Equality
    // C#:
    throw UnimplementedError('op_Equality not implemented');
  }

  /// Returns a value indicating whether two [TextToSpeechResponseUpdateKind]
  /// instances are not equivalent, as determined by a case-insensitive
  /// comparison of their values.
  ///
  /// Returns: `true` if left and right have different values; `false` if they
  /// have equivalent values or are both null.
  ///
  /// [left] The first [TextToSpeechResponseUpdateKind] instance to compare.
  ///
  /// [right] The second [TextToSpeechResponseUpdateKind] instance to compare.
  static bool op_Inequality(
    TextToSpeechResponseUpdateKind left,
    TextToSpeechResponseUpdateKind right,
  ) {
    // TODO: implement op_Inequality
    // C#:
    throw UnimplementedError('op_Inequality not implemented');
  }

  @override
  bool equals({Object? obj, TextToSpeechResponseUpdateKind? other, }) {
    return obj is TextToSpeechResponseUpdateKind otherKind && equals(otherKind);
  }

  @override
  int getHashCode() {
    return value == null ? 0 : StringComparer.ordinalIgnoreCase.getHashCode(value);
  }

  @override
  String toString() {
    return value;
  }

  @override
  bool operator ==(Object other) { if (identical(this, other)) return true;
    return other is TextToSpeechResponseUpdateKind &&
    sessionOpen == other.sessionOpen &&
    error == other.error &&
    audioUpdating == other.audioUpdating &&
    audioUpdated == other.audioUpdated &&
    sessionClose == other.sessionClose &&
    value == other.value; }
  @override
  int get hashCode { return Object.hash(
    sessionOpen,
    error,
    audioUpdating,
    audioUpdated,
    sessionClose,
    value,
  ); }
}
/// Provides a [JsonConverter] for serializing
/// [TextToSpeechResponseUpdateKind] instances.
class Converter extends JsonConverter<TextToSpeechResponseUpdateKind> {
  Converter();

  @override
  TextToSpeechResponseUpdateKind read(
    Utf8JsonReader reader,
    Type typeToConvert,
    JsonSerializerOptions options,
  ) {
    return new(reader.getString()!);
  }

  @override
  void write(
    Utf8JsonWriter writer,
    TextToSpeechResponseUpdateKind value,
    JsonSerializerOptions options,
  ) {
    Throw.ifNull(writer).writeStringValue(value.value);
  }
}
