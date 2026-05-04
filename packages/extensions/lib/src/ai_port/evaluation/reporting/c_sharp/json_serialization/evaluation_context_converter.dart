import '../../../../abstractions/contents/ai_content.dart';
import '../../../evaluation_context.dart';

class EvaluationContextConverter extends JsonConverter<EvaluationContext> {
  EvaluationContextConverter();

  @override
  EvaluationContext read(
    Utf8JsonReader reader,
    Type typeToConvert,
    JsonSerializerOptions options,
  ) {
    if (reader.tokenType is! JsonTokenType.startObject) {
      throw jsonException('Unexpected token '${reader.tokenType}'.');
    }
    var name = null;
    var contents = null;
    while (reader.read()) {
      if (reader.tokenType is JsonTokenType.endObject || (name != null&& contents != null)) {
        break;
      }
      if (reader.tokenType is JsonTokenType.propertyName) {
        var propertyName = reader.getString()!;
        if (!reader.read()) {
          throw jsonException(
                        'Failed to read past the '${JsonTokenType.propertyName}' token for property with name '${propertyName}'.');
        }
        switch (propertyName) {
          case NamePropertyName:
          if (reader.tokenType is! JsonTokenType.string) {
            throw jsonException(
                                'Expected '${JsonTokenType.string}' but found '${reader.tokenType}' after '${JsonTokenType.propertyName}' token for property with name '${propertyName}'.');
          }
          name = reader.getString();
          case ContentsPropertyName:
          if (reader.tokenType is! JsonTokenType.startArray) {
            throw jsonException(
                                'Expected '${JsonTokenType.startArray}' but found '${reader.tokenType}' after '${JsonTokenType.propertyName}' token for property with name '${propertyName}'.');
          }
          var contentsTypeInfo = options.getTypeInfo(typeof(IReadOnlyList<AContent>));
          contents = JsonSerializer.deserialize(
            ref reader,
            contentsTypeInfo,
          ) as IReadOnlyList<AContent>;
        }
      }
    }
    if (name == null|| contents == null) {
      throw jsonException('Missing required properties '${NamePropertyName}' and '${ContentsPropertyName}'.');
    }
    return deserializedEvaluationContext(name, contents);
  }

  @override
  void write(Utf8JsonWriter writer, EvaluationContext value, JsonSerializerOptions options, ) {
    writer.writeStartObject();
    writer.writeString(NamePropertyName, value.name);
    writer.writePropertyName(ContentsPropertyName);
    var contentsTypeInfo = options.getTypeInfo(typeof(IReadOnlyList<AContent>));
    JsonSerializer.serialize(writer, value.contents, contentsTypeInfo);
    writer.writeEndObject();
  }
}
class DeserializedEvaluationContext extends EvaluationContext {
  const DeserializedEvaluationContext(String name, List<AContent> contents, );

}
