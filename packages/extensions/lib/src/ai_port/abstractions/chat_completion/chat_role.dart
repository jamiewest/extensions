/// Describes the intended purpose of a message within a chat interaction.
class ChatRole {
  /// Initializes a new instance of the [ChatRole] struct with the provided
  /// value.
  ///
  /// [value] The value to associate with this [ChatRole].
  const ChatRole(String value) : value = Throw.ifNullOrWhitespace(value);

  /// Gets the role that instructs or sets the behavior of the system.
  static final ChatRole system = new("system");

  /// Gets the role that provides responses to system-instructed, user-prompted
  /// input.
  static final ChatRole assistant = new("assistant");

  /// Gets the role that provides user input for chat interactions.
  static final ChatRole user = new("user");

  /// Gets the role that provides additional information and references in
  /// response to tool use requests.
  static final ChatRole tool = new("tool");

  /// Gets the value associated with this [ChatRole].
  ///
  /// Remarks: The value will be serialized into the "role" message field of the
  /// Chat Message format.
  final String value;

  /// Returns a value indicating whether two [ChatRole] instances are
  /// equivalent, as determined by a case-insensitive comparison of their
  /// values.
  ///
  /// Returns: `true` if left and right are both `null` or have equivalent
  /// values; otherwise, `false`.
  ///
  /// [left] The first [ChatRole] instance to compare.
  ///
  /// [right] The second [ChatRole] instance to compare.
  static bool op_Equality(ChatRole left, ChatRole right, ) {
    // TODO: implement op_Equality
    // C#:
    throw UnimplementedError('op_Equality not implemented');
  }

  /// Returns a value indicating whether two [ChatRole] instances are not
  /// equivalent, as determined by a case-insensitive comparison of their
  /// values.
  ///
  /// Returns: `true` if left and right have different values; `false` if they
  /// have equivalent values or are both `null`.
  ///
  /// [left] The first [ChatRole] instance to compare.
  ///
  /// [right] The second [ChatRole] instance to compare.
  static bool op_Inequality(ChatRole left, ChatRole right, ) {
    // TODO: implement op_Inequality
    // C#:
    throw UnimplementedError('op_Inequality not implemented');
  }

  @override
  bool equals({Object? obj, ChatRole? other, }) {
    return obj is ChatRole otherRole && equals(otherRole);
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
    return other is ChatRole &&
    system == other.system &&
    assistant == other.assistant &&
    user == other.user &&
    tool == other.tool &&
    value == other.value; }
  @override
  int get hashCode { return Object.hash(system, assistant, user, tool, value); }
}
/// Provides a [JsonConverter] for serializing [ChatRole] instances.
class Converter extends JsonConverter<ChatRole> {
  Converter();

  @override
  ChatRole read(Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options, ) {
    return new(reader.getString()!);
  }

  @override
  void write(Utf8JsonWriter writer, ChatRole value, JsonSerializerOptions options, ) {
    Throw.ifNull(writer).writeStringValue(value.value);
  }
}
