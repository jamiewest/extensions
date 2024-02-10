import 'instrument_rule.dart';

/// Options for configuring the metrics system.
class MetricsOptions {
  MetricsOptions() : rules = <InstrumentRule>[];

  /// A list of [InstrumentRule]'s that identify which metrics,
  /// instruments, and listeners are enabled.
  final List<InstrumentRule> rules;
}
