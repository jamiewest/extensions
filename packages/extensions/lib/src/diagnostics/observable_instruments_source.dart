import 'metrics_listener.dart';

/// An interface registered with each [MetricsListener] using
/// [MetricsListener.initialize(ObservableInstrumentsSource)]. The listener
/// can call [recordObservableInstruments] to receive the current set of
/// measurements for enabled observable instruments.
abstract interface class ObservableInstrumentsSource {
  /// Requests that the current set of metrics for enabled instruments be
  /// sent to the listener's [MeasurementCallback{T}]'s.
  void recordObservableInstruments();
}
