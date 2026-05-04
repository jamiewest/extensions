/// Represents options for configuring voice activity detection (VAD) in a
/// real-time session.
///
/// Remarks: Voice activity detection automatically determines when a user
/// starts and stops speaking, enabling natural turn-taking in conversational
/// audio interactions. When [Enabled] is `true`, the server detects speech
/// boundaries and manages turn transitions automatically. When [Enabled] is
/// `false`, the client must explicitly signal activity boundaries (e.g., via
/// audio buffer commit and response creation).
class VoiceActivityDetectionOptions {
  /// Initializes a new instance of the [VoiceActivityDetectionOptions] class.
  const VoiceActivityDetectionOptions();

  /// Gets or sets a value indicating whether server-side voice activity
  /// detection is enabled.
  ///
  /// Remarks: When `true`, the server automatically detects speech start and
  /// end, and may automatically trigger responses when the user stops speaking.
  /// When `false`, turn detection is fully disabled and the client controls
  /// turn boundaries manually (e.g., via audio buffer commit and explicit
  /// response creation). Other properties on this class, such as
  /// [AllowInterruption], only take effect when this property is `true`. The
  /// default is `true`.
  bool enabled = true;

  /// Gets or sets a value indicating whether the user's speech can interrupt
  /// the model's audio output.
  ///
  /// Remarks: This property is only meaningful when [Enabled] is `true`. When
  /// voice activity detection is disabled, the server does not detect speech,
  /// so interruption does not apply. When `true`, the model's response will be
  /// cut off when the user starts speaking (barge-in). When `false`, the
  /// model's response will continue to completion regardless of user input. The
  /// default is `true`. Not all providers support this option; those that do
  /// not will ignore it.
  bool allowInterruption = true;
}
