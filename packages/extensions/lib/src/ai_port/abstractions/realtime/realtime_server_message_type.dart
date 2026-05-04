/// Represents the type of a real-time server message. This is used to
/// identify the message type being received from the model.
///
/// Remarks: Well-known message types are provided as static properties.
/// Providers may define additional message types by constructing new
/// instances with custom values. Provider implementations that want to
/// support the built-in middleware pipeline
/// (`FunctionInvokingRealtimeClientSession` and
/// `OpenTelemetryRealtimeClientSession`) must emit the following message
/// types at appropriate points during response generation: [ResponseCreated]
/// — when the model begins generating a new response. [ResponseDone] — when
/// the model has finished generating a response (with usage data if
/// available). [ResponseOutputItemAdded] — when a new output item (e.g.,
/// function call, message) is added during response generation.
/// [ResponseOutputItemDone] — when an individual output item has completed.
/// This is required for function invocation middleware to detect and invoke
/// tool calls.
class RealtimeServerMessageType {
  /// Initializes a new instance of the [RealtimeServerMessageType] struct with
  /// the provided value.
  ///
  /// [value] The value to associate with this [RealtimeServerMessageType].
  const RealtimeServerMessageType(String value) : value = Throw.ifNullOrWhitespace(value);

  /// Gets a message type indicating that the response contains only raw
  /// content.
  ///
  /// Remarks: This type supports extensibility for custom content types not
  /// natively supported by the SDK.
  static final RealtimeServerMessageType rawContentOnly = new("RawContentOnly");

  /// Gets a message type indicating the output of audio transcription for user
  /// audio written to the user audio buffer.
  static final RealtimeServerMessageType inputAudioTranscriptionCompleted = new("InputAudioTranscriptionCompleted");

  /// Gets a message type indicating the text value of an input audio
  /// transcription content part is updated with incremental transcription
  /// results.
  static final RealtimeServerMessageType inputAudioTranscriptionDelta = new("InputAudioTranscriptionDelta");

  /// Gets a message type indicating that the audio transcription for user audio
  /// written to the user audio buffer has failed.
  static final RealtimeServerMessageType inputAudioTranscriptionFailed = new("InputAudioTranscriptionFailed");

  /// Gets a message type indicating the output text update with incremental
  /// results.
  static final RealtimeServerMessageType outputTextDelta = new("OutputTextDelta");

  /// Gets a message type indicating the output text is complete.
  static final RealtimeServerMessageType outputTextDone = new("OutputTextDone");

  /// Gets a message type indicating the model-generated transcription of audio
  /// output updated.
  static final RealtimeServerMessageType outputAudioTranscriptionDelta = new("OutputAudioTranscriptionDelta");

  /// Gets a message type indicating the model-generated transcription of audio
  /// output is done streaming.
  static final RealtimeServerMessageType outputAudioTranscriptionDone = new("OutputAudioTranscriptionDone");

  /// Gets a message type indicating the audio output updated.
  static final RealtimeServerMessageType outputAudioDelta = new("OutputAudioDelta");

  /// Gets a message type indicating the audio output is done streaming.
  static final RealtimeServerMessageType outputAudioDone = new("OutputAudioDone");

  /// Gets a message type indicating the response has completed.
  static final RealtimeServerMessageType responseDone = new("ResponseDone");

  /// Gets a message type indicating the response has been created.
  static final RealtimeServerMessageType responseCreated = new("ResponseCreated");

  /// Gets a message type indicating an individual output item in the response
  /// has completed.
  static final RealtimeServerMessageType responseOutputItemDone = new("ResponseOutputItemDone");

  /// Gets a message type indicating an individual output item has been added to
  /// the response.
  static final RealtimeServerMessageType responseOutputItemAdded = new("ResponseOutputItemAdded");

  /// Gets a message type indicating a conversation item has been added.
  static final RealtimeServerMessageType conversationItemAdded = new("ConversationItemAdded");

  /// Gets a message type indicating a conversation item is complete.
  static final RealtimeServerMessageType conversationItemDone = new("ConversationItemDone");

  /// Gets a message type indicating an error occurred while processing the
  /// request.
  static final RealtimeServerMessageType error = new("Error");

  /// Gets the value associated with this [RealtimeServerMessageType].
  final String value;

  /// Returns a value indicating whether two [RealtimeServerMessageType]
  /// instances are equivalent, as determined by a case-insensitive comparison
  /// of their values.
  ///
  /// Returns: `true` if left and right have equivalent values; otherwise,
  /// `false`.
  ///
  /// [left] The first instance to compare.
  ///
  /// [right] The second instance to compare.
  static bool op_Equality(RealtimeServerMessageType left, RealtimeServerMessageType right, ) {
    // TODO: implement op_Equality
    // C#:
    throw UnimplementedError('op_Equality not implemented');
  }

  /// Returns a value indicating whether two [RealtimeServerMessageType]
  /// instances are not equivalent, as determined by a case-insensitive
  /// comparison of their values.
  ///
  /// Returns: `true` if left and right have different values; otherwise,
  /// `false`.
  ///
  /// [left] The first instance to compare.
  ///
  /// [right] The second instance to compare.
  static bool op_Inequality(RealtimeServerMessageType left, RealtimeServerMessageType right, ) {
    // TODO: implement op_Inequality
    // C#:
    throw UnimplementedError('op_Inequality not implemented');
  }

  @override
  bool equals({Object? obj, RealtimeServerMessageType? other, }) {
    return obj is RealtimeServerMessageType other && equals(other);
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
    return other is RealtimeServerMessageType &&
    rawContentOnly == other.rawContentOnly &&
    inputAudioTranscriptionCompleted == other.inputAudioTranscriptionCompleted &&
    inputAudioTranscriptionDelta == other.inputAudioTranscriptionDelta &&
    inputAudioTranscriptionFailed == other.inputAudioTranscriptionFailed &&
    outputTextDelta == other.outputTextDelta &&
    outputTextDone == other.outputTextDone &&
    outputAudioTranscriptionDelta == other.outputAudioTranscriptionDelta &&
    outputAudioTranscriptionDone == other.outputAudioTranscriptionDone &&
    outputAudioDelta == other.outputAudioDelta &&
    outputAudioDone == other.outputAudioDone &&
    responseDone == other.responseDone &&
    responseCreated == other.responseCreated &&
    responseOutputItemDone == other.responseOutputItemDone &&
    responseOutputItemAdded == other.responseOutputItemAdded &&
    conversationItemAdded == other.conversationItemAdded &&
    conversationItemDone == other.conversationItemDone &&
    error == other.error &&
    value == other.value; }
  @override
  int get hashCode { return Object.hash(
    rawContentOnly,
    inputAudioTranscriptionCompleted,
    inputAudioTranscriptionDelta,
    inputAudioTranscriptionFailed,
    outputTextDelta,
    outputTextDone,
    outputAudioTranscriptionDelta,
    outputAudioTranscriptionDone,
    outputAudioDelta,
    outputAudioDone,
    responseDone,
    responseCreated,
    responseOutputItemDone,
    responseOutputItemAdded,
    conversationItemAdded,
    conversationItemDone,
    error,
    value,
  ); }
}
/// Provides a [JsonConverter] for serializing [RealtimeServerMessageType]
/// instances.
class Converter extends JsonConverter<RealtimeServerMessageType> {
  Converter();

  @override
  RealtimeServerMessageType read(
    Utf8JsonReader reader,
    Type typeToConvert,
    JsonSerializerOptions options,
  ) {
    return new(reader.getString()!);
  }

  @override
  void write(
    Utf8JsonWriter writer,
    RealtimeServerMessageType value,
    JsonSerializerOptions options,
  ) {
    Throw.ifNull(writer).writeStringValue(value.value);
  }
}
