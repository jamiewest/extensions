import 'measurement_handlers.dart';
import 'observable_instruments_source.dart';

import 'system/diagnostics.dart';

/// Represents a type used to listen to metrics emitted from the system.
abstract class MetricsListener {
  String get name;

  /// Called once by the runtime to provide a [ObservableInstrumentsSource]
  /// used to pull for fresh metrics data.
  void initialize(ObservableInstrumentsSource source);

  /// Called when a new instrument is created and enabled by a matching rule.
  (bool, Object?) instrumentPublished(Instrument instrument);

  /// Called when a instrument is disabled by the producer or a rules change.
  void measurementsCompleted(Instrument instrument, Object? userState);

  /// Called once to get the [MeasurementHandlers] that will be used to
  /// process measurements.
  MeasurementHandlers getMeasurementHandlers();
}
