/// Represents options for configuring real-time audio.
///
/// This is an experimental feature.
class RealtimeAudioFormat {
  /// Creates a new [RealtimeAudioFormat] with the given [mediaType] and
  /// [sampleRate].
  RealtimeAudioFormat(this.mediaType, this.sampleRate);

  /// The media type of the audio (e.g., "audio/pcm", "audio/pcmu",
  /// "audio/pcma").
  final String mediaType;

  /// The sample rate of the audio in Hertz.
  final int sampleRate;
}
