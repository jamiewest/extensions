import 'package:extensions/src/system/exceptions/argument_out_of_range_exception.dart';

import '../system/enum.dart';

import 'meter_scope.dart';
import 'system/diagnostics.dart';

/// Contains a set of parameters used to determine which instruments are
/// enabled for which listeners. Unspecified parameters match anything.
class InstrumentRule {
  final int _scopes;

  const InstrumentRule({
    this.meterName,
    this.instrumentName,
    this.listenerName,
    required int scopes,
    this.enable = false,
  }) : _scopes = scopes;

  /// Gets the [Meter.name], either an exact match or the longest prefix match.
  final String? meterName;

  // Gets the [Instrument.name], an exact match.
  final String? instrumentName;

  // Gets the [MetricsListener.name], an exact match.
  final String? listenerName;

  /// Gets the [MeterScope].
  int get scopes {
    if (_scopes.hasFlag(MeterScope.none)) {
      // TODO: Complete with parameters.
      throw ArgumentOutOfRangeException();
    }
    return _scopes;
  }

  /// Gets a value that indicates whether the instrument should be enabled
  /// for the listener.
  final bool enable;
}
