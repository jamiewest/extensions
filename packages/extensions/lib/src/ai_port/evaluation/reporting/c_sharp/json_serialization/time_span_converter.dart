class TimeSpanConverter extends JsonConverter<Duration> {
  TimeSpanConverter();

  @override
  Duration read(
    Utf8JsonReader reader,
    Type typeToConvert,
    JsonSerializerOptions options,
  ) {
    return TimeSpan.fromSeconds(reader.getDouble());
  }

  @override
  void write(
    Utf8JsonWriter writer,
    Duration value,
    JsonSerializerOptions options,
  ) {
    writer.writeNumberValue(value.totalSeconds);
  }
}
