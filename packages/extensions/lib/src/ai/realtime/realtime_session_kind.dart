/// Represents the kind of a real-time session.
///
/// This is an experimental feature.
class RealtimeSessionKind {
  /// Creates a new [RealtimeSessionKind] with the given [value].
  const RealtimeSessionKind(this.value);

  /// The value associated with this session kind.
  final String value;

  /// A conversation session.
  static const RealtimeSessionKind conversation = RealtimeSessionKind(
    'conversation',
  );

  /// A transcription-only session.
  ///
  /// When set, most session properties do not apply; only the input audio
  /// format and transcription options are used.
  static const RealtimeSessionKind transcription = RealtimeSessionKind(
    'transcription',
  );

  @override
  bool operator ==(Object other) =>
      other is RealtimeSessionKind &&
      value.toLowerCase() == other.value.toLowerCase();

  @override
  int get hashCode => value.toLowerCase().hashCode;

  @override
  String toString() => value;
}
