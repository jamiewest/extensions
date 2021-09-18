/// Identifies a logging event.
///
/// The primary identifier is the "Id" property, with the "Name"
/// property providing a short description of this type of event.
class EventId {
  /// Initializes an instance of the [EventId].
  const EventId(
    this.id,
    this.name,
  );

  /// Initializes an empty instance of [EventId].
  factory EventId.empty() => const EventId(0, null);

  /// The numeric identifer for this event.
  final int id;

  /// The name of this event.
  final String? name;

  @override
  String toString() => name ?? id.toString();

  @override
  bool operator ==(Object other) => (other is EventId) && id == other.id;

  @override
  int get hashCode => id;
}
