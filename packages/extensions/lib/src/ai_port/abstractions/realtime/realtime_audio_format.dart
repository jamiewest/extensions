/// Represents options for configuring real-time audio.
class RealtimeAudioFormat {
  /// Initializes a new instance of the [RealtimeAudioFormat] class.
  const RealtimeAudioFormat(String mediaType, int sampleRate)
    : mediaType = mediaType,
      sampleRate = sampleRate;

  /// Gets the media type of the audio (e.g., "audio/pcm", "audio/pcmu",
  /// "audio/pcma").
  String mediaType;

  /// Gets the sample rate of the audio in Hertz.
  int sampleRate;
}
