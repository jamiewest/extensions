/// Represents the options for a speech-to-text transcription session.
///
/// This is an experimental feature.
class TranscriptionOptions {
  /// Creates a new [TranscriptionOptions].
  TranscriptionOptions({
    this.speechLanguage,
    this.modelId,
    this.prompt,
  });

  /// The language of the input speech.
  String? speechLanguage;

  /// The model to use for transcription.
  String? modelId;

  /// An optional prompt to guide the transcription.
  String? prompt;
}
