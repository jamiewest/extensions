import 'package:extensions/annotations.dart';

/// Represents options for configuring real-time audio.
///
/// This is an experimental feature.
@Source(
  name: 'RealtimeAudioFormat.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Realtime/',
  commit: '2e537166e4231e50cceb66832b9dfd1382e24d1b',
)
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
