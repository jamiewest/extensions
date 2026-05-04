/// Represents an embedding composed of a bit vector.
class BinaryEmbedding extends Embedding {
  /// Initializes a new instance of the [BinaryEmbedding] class with the
  /// embedding vector.
  ///
  /// [vector] The embedding vector this embedding represents.
  BinaryEmbedding(BitArray vector) : vector = vector, _vector = Throw.ifNull(vector);

  /// The embedding vector this embedding represents.
  BitArray _vector;

  /// Gets or sets the embedding vector this embedding represents.
  BitArray vector;

  int get dimensions {
    return _vector.length;
  }
}
/// Provides a [JsonConverter] for serializing [BitArray] instances.
class VectorConverter extends JsonConverter<BitArray> {
  VectorConverter();

  @override
  BitArray read(Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options, ) {
    _ = Throw.ifNull(typeToConvert);
    _ = Throw.ifNull(options);
    if (reader.tokenType != JsonTokenType.string) {
      throw jsonException("Expected string property.");
    }
    ReadOnlySpan<byte> utf8;
    var tmpArray = null;
    if (!reader.hasValueSequence && !reader.valueIsEscaped) {
      utf8 = reader.valueSpan;
    } else {
      var length = reader.hasValueSequence ? checked((int)reader.valueSequence.length) : reader.valueSpan.length;
      tmpArray = ArrayPool<byte>.shared.rent(length);
      utf8 = tmpArray.asSpan(0, reader.copyString(tmpArray));
    }
    var result = new(utf8.length);
    for (var i = 0; i < utf8.length; i++) {
      result[i] = utf8[i] switch
                {
                    (byte)'0' => false,
                    (byte)'1' => true,
                    (_) => throw jsonException("Expected binary character sequence.")
                };
    }
    if (tmpArray != null) {
      ArrayPool<byte>.shared.returnValue(tmpArray);
    }
    return result;
  }

  @override
  void write(Utf8JsonWriter writer, BitArray value, JsonSerializerOptions options, ) {
    _ = Throw.ifNull(writer);
    _ = Throw.ifNull(value);
    _ = Throw.ifNull(options);
    var length = value.length;
    var tmpArray = ArrayPool<byte>.shared.rent(length);
    var utf8 = tmpArray.asSpan(0, length);
    for (var i = 0; i < utf8.length; i++) {
      utf8[i] = value[i] ? (byte)'1' : (byte)'0';
    }
    writer.writeStringValue(utf8);
    ArrayPool<byte>.shared.returnValue(tmpArray);
  }
}
