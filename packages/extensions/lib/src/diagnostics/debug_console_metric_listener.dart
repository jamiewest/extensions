import 'package:async/async.dart';
import 'package:extensions/src/diagnostics/console_metrics.dart';
import 'package:extensions/src/diagnostics/measurement_handlers.dart';
import 'package:extensions/src/diagnostics/metrics_listener.dart';
import 'package:extensions/src/diagnostics/observable_instruments_source.dart';
import 'package:extensions/src/diagnostics/system/diagnostics.dart';

import '../common/disposable.dart';

class DebugConsoleMetricListener implements MetricsListener, Disposable {
  RestartableTimer? _timer;
  ObservableInstrumentsSource? _source;

  @override
  String get name => ConsoleMetrics.debugListenerName;

  @override
  (bool, Object?) instrumentPublished(Instrument instrument) {
    if (instrument.isObservable && _timer == null) {
      _timer = RestartableTimer(
        const Duration(seconds: 1),
        () => _source?.recordObservableInstruments(),
      );
    }

    print(
      '${instrument.meter.name}-${instrument.name} Started; '
      'Description: ${instrument.description}.',
    );

    return (true, this);
  }

  @override
  void dispose() => _timer?.cancel();

  @override
  MeasurementHandlers getMeasurementHandlers() => MeasurementHandlers()
    ..doubleHandler = _measurementHandler
    ..intHandler = _measurementHandler;

  @override
  void initialize(ObservableInstrumentsSource source) => _source = source;

  @override
  void measurementsCompleted(Instrument instrument, Object? userState) {
    assert(userState == this);
    print('${instrument.meter.name}-${instrument.name} Stopped.');
  }

  void _measurementHandler<T>(
    Instrument instrument,
    T measurement,
    Map<String, Object?>? tags,
    Object? state,
  ) {
    assert(state == this);
    print(
      '${instrument.meter.name}-${instrument.name} '
      '$measurement ${instrument.unit}.',
    );
  }
}
