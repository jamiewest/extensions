part of 'diagnostics.dart';

typedef Instrument = TypedInstrument<Never>;

/// Base class of all Metrics Instrument classes
abstract final class TypedInstrument<T> {
  TypedInstrument({
    required this.meter,
    required this.name,
    this.description,
    this.unit,
    this.tags,
    this.isObservable = false,
  });

  /// Gets the Meter which created the instrument.
  final Meter meter;

  /// Gets the instrument name.
  final String name;

  /// Gets the instrument description.
  final String? description;

  /// Gets the instrument unit of measurements.
  final String? unit;

  /// Returns the tags associated with the instrument.
  final Map<String, Object?>? tags;

  /// Checks if there is any listeners for this instrument.
  bool get enabled => false;

  /// A property tells if the instrument is an observable instrument.
  final bool isObservable;

  void _notifyForUnpublishedInstrument() {}

  void recordMeasurement(
    T measurement,
    Map<String, Object?> tags,
  ) {
    // var current = _subscriptions.first;
    // while (current != null) {
    //   current.
    // }
  }
}
