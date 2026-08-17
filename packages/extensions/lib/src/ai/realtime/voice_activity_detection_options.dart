/// Represents voice activity detection (VAD) options for a real-time session.
///
/// This is an experimental feature.
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
