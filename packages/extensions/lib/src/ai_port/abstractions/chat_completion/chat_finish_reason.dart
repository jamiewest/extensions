/// Represents the reason a chat response completed.
class ChatFinishReason {
  /// Initializes a new instance of the [ChatFinishReason] struct with a string
  /// that describes the reason.
  ///
  /// [value] The reason value.
  const ChatFinishReason(String value) : value = Throw.ifNullOrWhitespace(value);

  /// Gets a [ChatFinishReason] representing the model encountering a natural
  /// stop point or provided stop sequence.
  static final ChatFinishReason stop = new("stop");

  /// Gets a [ChatFinishReason] representing the model reaching the maximum
  /// length allowed for the request and/or response (typically in terms of
  /// tokens).
  static final ChatFinishReason length = new("length");

  /// Gets a [ChatFinishReason] representing the model requesting the use of a
  /// tool that was defined in the request.
  static final ChatFinishReason toolCalls = new("tool_calls");

  /// Gets a [ChatFinishReason] representing the model filtering content,
  /// whether for safety, prohibited content, sensitive content, or other such
  /// issues.
  static final ChatFinishReason contentFilter = new("content_filter");

  /// Gets the finish reason value.
  String get value {
    return field ?? stop.value;
  }

  @override
  bool equals({Object? obj, ChatFinishReason? other, }) {
    return obj is ChatFinishReason other && equals(other);
  }

  @override
  int getHashCode() {
    return StringComparer.ordinalIgnoreCase.getHashCode(value);
  }

  /// Compares two instances.
  ///
  /// Returns: `true` if the two instances are equal; `false` if they aren't
  /// equal.
  ///
  /// [left] The left argument of the comparison.
  ///
  /// [right] The right argument of the comparison.
  static bool op_Equality(ChatFinishReason left, ChatFinishReason right, ) {
    // TODO: implement op_Equality
    // C#:
    throw UnimplementedError('op_Equality not implemented');
  }

  /// Compares two instances.
  ///
  /// Returns: `true` if the two instances aren't equal; `false` if they are
  /// equal.
  ///
  /// [left] The left argument of the comparison.
  ///
  /// [right] The right argument of the comparison.
  static bool op_Inequality(ChatFinishReason left, ChatFinishReason right, ) {
    // TODO: implement op_Inequality
    // C#:
    throw UnimplementedError('op_Inequality not implemented');
  }

  /// Gets the [Value] of the finish reason.
  ///
  /// Returns: The [Value] of the finish reason.
  @override
  String toString() {
    return value;
  }

  @override
  bool operator ==(Object other) { if (identical(this, other)) return true;
    return other is ChatFinishReason &&
    stop == other.stop &&
    length == other.length &&
    toolCalls == other.toolCalls &&
    contentFilter == other.contentFilter; }
  @override
  int get hashCode { return Object.hash(stop, length, toolCalls, contentFilter); }
}
/// Provides a [JsonConverter] for serializing [ChatFinishReason] instances.
class Converter extends JsonConverter<ChatFinishReason> {
  Converter();

  @override
  ChatFinishReason read(
    Utf8JsonReader reader,
    Type typeToConvert,
    JsonSerializerOptions options,
  ) {
    return new(reader.getString()!);
  }

  @override
  void write(Utf8JsonWriter writer, ChatFinishReason value, JsonSerializerOptions options, ) {
    Throw.ifNull(writer).writeStringValue(value.value);
  }
}
