part of diagnostics;

/// A delegate to represent the MeterListener callbacks used in
/// measurements recording operation.
typedef MeasurementCallback = void Function<T>(
  Instrument instrument,
  T measurement,
  Map<String, Object?>? tags,
  Object? state,
);

/// MeterListener is class used to listen to the metrics instrument
/// measurements recording.
class MeterListener implements Disposable {
  static final _allStartedListners = <MeterListener>[];
  final _enabledMeasurementInstruments = <Instrument>[];
  bool _disposed = false;

  /// Creates a MeterListener object.
  MeterListener();

  /// Callbacks to get notification when an instrument is published.
  void Function(
    Instrument instrument,
    MeterListener meterListener,
  )? instrumentPublished;

  void Function(
    Instrument instrument,
    Object? object,
  )? measurementsCompleted;

  /// Start listening to a specific instrument measurement recording.
  void enabledMeasurementEvents(Instrument instrument, Object? state) {
    if (!Meter._isSupported) {
      return;
    }

    bool oldStateStored = false;
    bool enabled = false;
    Object? oldState;

    if (!_disposed && !instrument.meter._disposed) {_enabledMeasurementInstruments.}
  }

  @override
  void dispose() {}
}
