import '../open_telemetry_consts.dart';

/// Represents the response to a chat request with structured output.
///
/// Remarks: Language models are not guaranteed to honor the requested schema.
/// If the model's output is not parseable as the expected type, then
/// [TryGetResult(@)] will return `false`. You can access the underlying JSON
/// response on the [Text] property.
///
/// [T] The type of value expected from the chat response.
class ChatResponse<T> extends ChatResponse {
  /// Initializes a new instance of the [ChatResponse] class.
  ///
  /// [response] The unstructured [ChatResponse] that is being wrapped.
  ///
  /// [serializerOptions] The [JsonSerializerOptions] to use when deserializing
  /// the result.
  ChatResponse(
    ChatResponse response,
    JsonSerializerOptions serializerOptions,
  ) : _serializerOptions = Throw.ifNull(serializerOptions) {
    AdditionalProperties = response.additionalProperties;
    ConversationId = response.conversationId;
    CreatedAt = response.createdAt;
    FinishReason = response.finishReason;
    ModelId = response.modelId;
    RawRepresentation = response.rawRepresentation;
    ResponseId = response.responseId;
    Usage = response.usage;
  }

  static final JsonReaderOptions _allowMultipleValuesJsonReaderOptions;

  final JsonSerializerOptions _serializerOptions;

  T? _deserializedResult;

  bool _hasDeserializedResult;

  /// Gets the result value of the chat response as an instance of `T`.
  ///
  /// Remarks: If the response did not contain JSON, or if deserialization
  /// fails, this property will throw. To avoid exceptions, use
  /// [TryGetResult(@)] instead.
  final T result;

  /// Gets or sets a value indicating whether the JSON schema has an extra
  /// object wrapper.
  ///
  /// Remarks: The wrapper is required for any non-JSON-object-typed values such
  /// as numbers, enum values, and arrays.
  bool isWrappedInObject;

  /// Attempts to deserialize the result to produce an instance of `T`.
  ///
  /// Returns: `true` if the result was produced, otherwise `false`.
  ///
  /// [result] When this method returns, contains the result.
  (bool, T??) tryGetResult() {
    var result = null;
    try {
      var failureReason = null;
      result = getResultCore(failureReason);
      return (failureReason == null, result);
    } catch (e, s) {
      result = default;
      return (false, result);
    }
  }

  static T? deserializeFirstTopLevelObject(String json, JsonTypeInfo<T> typeInfo, ) {
    var utf8ByteLength = Encoding.utF8.getByteCount(json);
    var buffer = ArrayPool<byte>.shared.rent(utf8ByteLength);
    try {
      var utf8SpanLength = Encoding.utF8.getBytes(json, 0, json.length, buffer, 0);
      var utf8Span = ReadOnlySpan<byte>(buffer, 0, utf8SpanLength);
      var reader = utf8JsonReader(utf8Span, _allowMultipleValuesJsonReaderOptions);
      return JsonSerializer.deserialize(ref reader, typeInfo);
    } finally {
      ArrayPool<byte>.shared.returnValue(buffer);
    }
  }

  (T?, FailureReason??) getResultCore() {
    var failureReason = null;
    if (_hasDeserializedResult) {
      failureReason = default;
      return (_deserializedResult, failureReason);
    }
    var json = Messages.count > 0 ? Messages[Messages.count - 1].text : string.empty;
    if (string.isNullOrEmpty(json)) {
      failureReason = FailureReason.resultDidNotContainJson;
      return (Future.value(), failureReason);
    }
    var deserialized = default;
    if (isWrappedInObject) {
      var data = null;
      if (JsonDocument.parse(json!).rootElement.tryGetProperty("data", data)) {
        json = data.getRawText();
      } else {
        failureReason = FailureReason.resultDidNotContainDataProperty;
        return (Future.value(), failureReason);
      }
    }
    deserialized = deserializeFirstTopLevelObject(
      json!,
      (JsonTypeInfo<T>)_serializerOptions.getTypeInfo(typeof(T)),
    );
    if (deserialized == null) {
      failureReason = FailureReason.deserializationProducedNull;
      return (Future.value(), failureReason);
    }
    _deserializedResult = deserialized;
    _hasDeserializedResult = true;
    failureReason = default;
    return (deserialized, failureReason);
  }
}
enum FailureReason { resultDidNotContainJson,
deserializationProducedNull,
resultDidNotContainDataProperty }
