/// Represents options for configuring transcription.
class TranscriptionOptions {
  /// Initializes a new instance of the [TranscriptionOptions] class.
  const TranscriptionOptions();

  /// Gets or sets the language of the input speech audio.
  ///
  /// Remarks: The language should be specified in ISO-639-1 format (e.g. "en").
  /// Supplying the input speech language improves transcription accuracy and
  /// latency.
  String? speechLanguage;

  /// Gets or sets the model ID to use for transcription.
  String? modelId;

  /// Gets or sets an optional prompt to guide the transcription.
  String? prompt;
}
