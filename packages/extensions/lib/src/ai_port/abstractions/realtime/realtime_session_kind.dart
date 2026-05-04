/// Represents the kind of a real-time session.
///
/// Remarks: Well-known session kinds are provided as static properties.
/// Providers may define additional session kinds by constructing new
/// instances with custom values.
class RealtimeSessionKind {
  /// Initializes a new instance of the [RealtimeSessionKind] struct with the
  /// provided value.
  ///
  /// [value] The value to associate with this [RealtimeSessionKind].
  const RealtimeSessionKind(String value) : value = Throw.ifNullOrWhitespace(value);

  /// Gets a session kind representing a conversational session which processes
  /// audio, text, or other media in real-time.
  static final RealtimeSessionKind conversation = new("conversation");

  /// Gets a session kind representing a transcription-only session.
  static final RealtimeSessionKind transcription = new("transcription");

  /// Gets the value of the session kind.
  final String value;

  /// Returns a value indicating whether two [RealtimeSessionKind] instances are
  /// equivalent, as determined by a case-insensitive comparison of their
  /// values.
  ///
  /// Returns: `true` if left and right have equivalent values; otherwise,
  /// `false`.
  ///
  /// [left] The first instance to compare.
  ///
  /// [right] The second instance to compare.
  static bool op_Equality(RealtimeSessionKind left, RealtimeSessionKind right, ) {
    // TODO: implement op_Equality
    // C#:
    throw UnimplementedError('op_Equality not implemented');
  }

  /// Returns a value indicating whether two [RealtimeSessionKind] instances are
  /// not equivalent, as determined by a case-insensitive comparison of their
  /// values.
  ///
  /// Returns: `true` if left and right have different values; otherwise,
  /// `false`.
  ///
  /// [left] The first instance to compare.
  ///
  /// [right] The second instance to compare.
  static bool op_Inequality(RealtimeSessionKind left, RealtimeSessionKind right, ) {
    // TODO: implement op_Inequality
    // C#:
    throw UnimplementedError('op_Inequality not implemented');
  }

  @override
  bool equals({Object? obj, RealtimeSessionKind? other, }) {
    return obj is RealtimeSessionKind other && equals(other);
  }

  @override
  int getHashCode() {
    return value == null ? 0 : StringComparer.ordinalIgnoreCase.getHashCode(value);
  }

  @override
  String toString() {
    return value ?? string.empty;
  }

  @override
  bool operator ==(Object other) { if (identical(this, other)) return true;
    return other is RealtimeSessionKind &&
    conversation == other.conversation &&
    transcription == other.transcription &&
    value == other.value; }
  @override
  int get hashCode { return Object.hash(conversation, transcription, value); }
}
/// Provides a [JsonConverter] for serializing [RealtimeSessionKind]
/// instances.
class Converter extends JsonConverter<RealtimeSessionKind> {
  Converter();

  @override
  RealtimeSessionKind read(
    Utf8JsonReader reader,
    Type typeToConvert,
    JsonSerializerOptions options,
  ) {
    return new(reader.getString()!);
  }

  @override
  void write(Utf8JsonWriter writer, RealtimeSessionKind value, JsonSerializerOptions options, ) {
    Throw.ifNull(writer).writeStringValue(value.value);
  }
}
