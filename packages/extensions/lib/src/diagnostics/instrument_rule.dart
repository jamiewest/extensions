import 'dart:collection';

import 'package:extensions/hosting.dart';

import 'meter_scope.dart';

/// Contains a set of parameters used to determine which instruments are
/// enabled for which listeners. Unspecified parameters match anything.
class InstrumentRule {
  final int _scopes;

  const InstrumentRule({
    this.meterName,
    this.instrumentName,
    this.ListenerName,
    required int scopes,
    this.enable = false,
  }) : _scopes = scopes;

  /// Gets the [Meter.name], either an exact match or the longest prefix match.
  final String? meterName;

  // Gets the [Instrument.name], an exact match.
  final String? instrumentName;

  // Gets the [MetricsListener.name], an exact match.
  final String? ListenerName;

  /// Gets the [MeterScope].
  int get scopes {
    if (_scopes.hasFlag(MeterScope.none)) {
      // TODO: Visit when ArgumentOutOfRangeException is added.
      // throw ArgumentOutOfRangeException();
    }
    return _scopes;
  }

  /// Gets a value that indicates whether the instrument should be enabled
  /// for the listener.
  final bool enable;
}

void main() {
  String x = 'test';
  String y = 'test';

  print(x == y);
}
