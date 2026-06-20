import 'package:extensions/annotations.dart';

/// Represents voice activity detection (VAD) options for a real-time session.
///
/// This is an experimental feature.
@Source(
  name: 'VoiceActivityDetectionOptions.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Realtime/',
  commit: '2e537166e4231e50cceb66832b9dfd1382e24d1b',
)
class VoiceActivityDetectionOptions {
  /// Creates a new [VoiceActivityDetectionOptions].
  VoiceActivityDetectionOptions({
    this.enabled = true,
    this.allowInterruption = true,
  });

  /// Whether voice activity detection is enabled.
  bool enabled;

  /// Whether the user is allowed to interrupt the model.
  bool allowInterruption;
}
