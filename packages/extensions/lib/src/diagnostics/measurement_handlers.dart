import 'system/diagnostics.dart';

/// A callback to represent the MeterListener callbacks used in
/// measurements recording operation.
typedef MeasurementCallback<TValue> = void Function(
  Instrument instrument,
  TValue measurement,
  Map<String, Object?> tags,
  Object? state,
);

/// A set of supported measurement types. If a listener does not support
/// a given type, the measurement will be skipped.
class MeasurementHandlers {
  /// A [MeasurementCallback] for [int].
  ///
  /// If null, int measurements will be skipped.
  MeasurementCallback<int>? intHandler;

  /// A [MeasurementCallback] for [double].
  ///
  /// If null, int measurements will be skipped.
  MeasurementCallback<double>? doubleHandler;
}
