/// Describes the intended purpose of a specific update during streaming of
/// speech to text updates.
class SpeechToTextResponseUpdateKind {
  /// Initializes a new instance of the [SpeechToTextResponseUpdateKind] struct
  /// with the provided value.
  ///
  /// [value] The value to associate with this [SpeechToTextResponseUpdateKind].
  const SpeechToTextResponseUpdateKind(String value) : value = Throw.ifNullOrWhitespace(value);

  /// Gets when the generated text session is opened.
  static final SpeechToTextResponseUpdateKind sessionOpen = new("sessionopen");

  /// Gets when a non-blocking error occurs during speech to text updates.
  static final SpeechToTextResponseUpdateKind error = new("error");

  /// Gets when the text update is in progress, without waiting for silence.
  static final SpeechToTextResponseUpdateKind textUpdating = new("textupdating");

  /// Gets when the text was generated after small period of silence.
  static final SpeechToTextResponseUpdateKind textUpdated = new("textupdated");

  /// Gets when the generated text session is closed.
  static final SpeechToTextResponseUpdateKind sessionClose = new("sessionclose");

  /// Gets the value associated with this [SpeechToTextResponseUpdateKind].
  ///
  /// Remarks: The value will be serialized into the "kind" message field of the
  /// speech to text update format.
  final String value;

  /// Returns a value indicating whether two [SpeechToTextResponseUpdateKind]
  /// instances are equivalent, as determined by a case-insensitive comparison
  /// of their values.
  ///
  /// Returns: `true` if left and right are both null or have equivalent values;
  /// otherwise, `false`.
  ///
  /// [left] The first [SpeechToTextResponseUpdateKind] instance to compare.
  ///
  /// [right] The second [SpeechToTextResponseUpdateKind] instance to compare.
  static bool op_Equality(
    SpeechToTextResponseUpdateKind left,
    SpeechToTextResponseUpdateKind right,
  ) {
    // TODO: implement op_Equality
    // C#:
    throw UnimplementedError('op_Equality not implemented');
  }

  /// Returns a value indicating whether two [SpeechToTextResponseUpdateKind]
  /// instances are not equivalent, as determined by a case-insensitive
  /// comparison of their values.
  ///
  /// Returns: `true` if left and right have different values; `false` if they
  /// have equivalent values or are both null.
  ///
  /// [left] The first [SpeechToTextResponseUpdateKind] instance to compare.
  ///
  /// [right] The second [SpeechToTextResponseUpdateKind] instance to compare.
  static bool op_Inequality(
    SpeechToTextResponseUpdateKind left,
    SpeechToTextResponseUpdateKind right,
  ) {
    // TODO: implement op_Inequality
    // C#:
    throw UnimplementedError('op_Inequality not implemented');
  }

  @override
  bool equals({Object? obj, SpeechToTextResponseUpdateKind? other, }) {
    return obj is SpeechToTextResponseUpdateKind otherRole && equals(otherRole);
  }

  @override
  int getHashCode() {
    return StringComparer.ordinalIgnoreCase.getHashCode(value);
  }

  @override
  String toString() {
    return value;
  }

  @override
  bool operator ==(Object other) { if (identical(this, other)) return true;
    return other is SpeechToTextResponseUpdateKind &&
    sessionOpen == other.sessionOpen &&
    error == other.error &&
    textUpdating == other.textUpdating &&
    textUpdated == other.textUpdated &&
    sessionClose == other.sessionClose &&
    value == other.value; }
  @override
  int get hashCode { return Object.hash(
    sessionOpen,
    error,
    textUpdating,
    textUpdated,
    sessionClose,
    value,
  ); }
}
/// Provides a [JsonConverter] for serializing
/// [SpeechToTextResponseUpdateKind] instances.
class Converter extends JsonConverter<SpeechToTextResponseUpdateKind> {
  Converter();

  @override
  SpeechToTextResponseUpdateKind read(
    Utf8JsonReader reader,
    Type typeToConvert,
    JsonSerializerOptions options,
  ) {
    return new(reader.getString()!);
  }

  @override
  void write(
    Utf8JsonWriter writer,
    SpeechToTextResponseUpdateKind value,
    JsonSerializerOptions options,
  ) {
    Throw.ifNull(writer).writeStringValue(value.value);
  }
}
