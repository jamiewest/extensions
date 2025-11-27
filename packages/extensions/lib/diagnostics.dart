/// Provides metrics and instrumentation support for application telemetry.
///
/// This library contains the default implementation of meter factory and
/// extension methods for registering metrics providers with dependency
/// injection, inspired by Microsoft.Extensions.Diagnostics.
///
/// ## Metrics Collection
///
/// Create and use meters for collecting application metrics:
///
/// ```dart
/// final meterFactory = provider.getRequiredService<MeterFactory>();
/// final meter = meterFactory.create('MyApp.Metrics');
///
/// // Create a counter
/// final requestCounter = meter.createCounter<int>('requests');
/// requestCounter.add(1);
///
/// // Create a histogram
/// final latencyHistogram = meter.createHistogram<double>('latency');
/// latencyHistogram.record(42.5);
/// ```
///
/// ## Metrics Listeners
///
/// Subscribe to metrics via listeners:
///
/// ```dart
/// services.addMetrics(builder => builder
///   .addListener<MyMetricsListener>());
/// ```
library;

import 'dart:collection';

import 'src/diagnostics/instrument_rule.dart';
import 'src/diagnostics/meter_factory.dart';
import 'src/diagnostics/meter_scope.dart';
import 'src/diagnostics/metrics_listener.dart';
import 'src/diagnostics/metrics_options.dart';
import 'src/diagnostics/observable_instruments_source.dart';
import 'src/diagnostics/system/diagnostics.dart';
import 'src/options/options_monitor.dart';
import 'src/system/disposable.dart';
import 'src/system/enum.dart';
import 'src/system/exceptions/invalid_operation_exception.dart';
import 'src/system/string.dart' as string;

export 'src/diagnostics/instrument_rule.dart';
export 'src/diagnostics/measurement_handlers.dart';
export 'src/diagnostics/meter_scope.dart';
export 'src/diagnostics/metrics_builder.dart';
export 'src/diagnostics/metrics_listener.dart';
export 'src/diagnostics/observable_instruments_source.dart';

part 'src/diagnostics/listener_subscription.dart';
part 'src/diagnostics/metrics_subscription_manager.dart';
