part of 'diagnostics.dart';

/// A delegate to represent the MeterListener callbacks used in
/// measurements recording operation.
typedef MeasurementCallback<T> = void Function(
  Instrument instrument,
  T measurement,
  Map<String, Object?>? tags,
  Object? state,
);

/// MeterListener is class used to listen to the metrics instrument
/// measurements recording.
class MeterListener implements Disposable {
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

    if (!_disposed && !instrument.meter._disposed) {
      // TODO: Implement measurement event enabling
    }
  }

  /// Stop listening to a specific instrument measurement recording.
  Object? disableMeasurementEvents(Instrument instrument) => null;

  /// Sets a callback for a specific numeric type to get the measurement
  /// recording notification from all instruments which enabled listening
  /// and was created with the same specified numeric type. If a measurement
  /// of type T is recorded and a callback of type T is registered, that
  /// callback will be used.
  void setMeasurementEventCallback<T>(
    MeasurementCallback<T>? measurementCallback,
  ) {
    if (!Meter._isSupported) {
      return;
    }
  }

  /// Enable the listener to start listening to instruments measurement
  /// recording.
  void start() {
    if (!Meter._isSupported) {
      return;
    }
  }

  /// Calls all Observable instruments which the listener is listening to
  /// then calls [setMeasurementEventCallback] with every collected measurement.
  void recordObservableInstruments() {
    if (!Meter._isSupported) {
      return;
    }
  }

  /// Disposes the listeners which will stop it from listening to any
  /// instrument.
  @override
  void dispose() {
    if (!Meter._isSupported) {
      return;
    }
  }
}
