part of '../../diagnostics.dart';

base class ListenerSubscription extends LinkedListEntry<ListenerSubscription>
    implements ObservableInstrumentsSource, Disposable {
  final MeterListener _meterListener;
  final MetricsListener _metricsListener;
  final MeterFactory _meterFactory;
  final Map<Instrument, Object?> _instruments = <Instrument, Object?>{};
  List<InstrumentRule> _rules = <InstrumentRule>[];
  bool _disposed = false;
  bool _disposing = false;

  ListenerSubscription(
    MetricsListener metricsListener,
    MeterFactory meterFactory,
  )   : _metricsListener = metricsListener,
        _meterFactory = meterFactory,
        _meterListener = MeterListener();

  void initialize() {
    _meterListener
      ..instrumentPublished = _instrumentPublished
      ..measurementsCompleted = _measurementsCompleted;
  }

  void _instrumentPublished(Instrument instrument, MeterListener _) {
    if (_disposed) {
      return;
    }

    if (_instruments.containsKey(instrument)) {
      assert(
        false,
        'InstrumentPublished called for an instrument '
        'we\'re already listening to.',
      );
      return;
    }

    _refreshInstrument(instrument);
  }

  void _measurementsCompleted(Instrument instrument, Object? state) {
    if (_disposed && !_disposing) {
      return;
    }

    if (_instruments.containsKey(instrument)) {
      final listenerState = _instruments[instrument];
      _instruments.remove(instrument);
      _metricsListener.measurementsCompleted(instrument, listenerState);
      // _metricsListener.disableMeasurementEvents(instrument);
    }
  }

  void _updateRules(List<InstrumentRule> rules) {
    if (_disposed) {
      return;
    }

    _rules = rules;

    // Get a fresh list of instruments to compare against the new rules.
    var tempListener = MeterListener()
      ..instrumentPublished = (instrument, _) => _refreshInstrument(instrument);
    // tempListener.start();
  }

  void _refreshInstrument(Instrument instrument) {
    var alreadyEnabled = _instruments.containsKey(instrument);
    var state = alreadyEnabled ? _instruments[instrument] : null;
    var enable = false;
    var rule = _getMostSpecificRule(instrument);
    if (rule != null) {
      enable = rule.enable;
    }

    if (!enable && alreadyEnabled) {
      _instruments.remove(instrument);
      _metricsListener.measurementsCompleted(instrument, state);
      // _metricsListener.disableMeasurementEvents(instrument);
    } else if (enable && !alreadyEnabled) {
      var result = _metricsListener.instrumentPublished(instrument);
      // First record field is boolean, if found, the second field
      // contains state.
      if (result.$1) {
        _instruments[instrument] = state;
        _meterListener.enabledMeasurementEvents(instrument, state);
      }
    }
  }

  InstrumentRule? _getMostSpecificRule(Instrument instrument) {
    InstrumentRule? best;
    for (var rule in _rules) {
      if (_ruleMatches(
              rule, instrument, _metricsListener.name, _meterFactory) &&
          _isMoreSpecific(
              rule, best, instrument.meter.scope == _meterFactory)) {
        best = rule;
      }
    }
    return best;
  }

  static bool _ruleMatches(
    InstrumentRule rule,
    Instrument instrument,
    String listenerName,
    MeterFactory meterFactory,
  ) {
    // Exact match or empty
    if (!string.isNullOrEmpty(rule.listenerName) &&
        !string.equals(rule.listenerName!, listenerName)) {
      return false;
    }

    // Exact match or empty
    if (!string.isNullOrEmpty(rule.instrumentName) &&
        !string.equals(rule.instrumentName!, instrument.name)) {
      return false;
    }

    if (!(rule.scopes.hasFlag(MeterScope.global) &&
            instrument.meter.scope == null) &&
        !(rule.scopes.hasFlag(MeterScope.local) &&
            instrument.meter.scope == meterFactory)) {
      return false;
    }

    // Meter
    // The same logic as Microsoft.Extensions.Logging.LoggerRuleSelector.
    //IsBetter for category names
    var meterName = rule.meterName;
    if (meterName != null) {
      const wildcardChar = '*';

      var wildcardIndex = meterName.indexOf(wildcardChar);
      if (wildcardIndex >= 0 &&
          meterName.indexOf(wildcardChar, wildcardIndex + 1) >= 0) {
        throw InvalidOperationException(message: 'SR.MoreThanOneWildcard');
      }

      String prefix, suffix;
      if (wildcardIndex < 0) {
        prefix = meterName;
        suffix = '';
      } else {
        prefix = meterName.substring(0, wildcardIndex);
        suffix = meterName.substring(wildcardIndex + 1);
      }

      /// TODO: Should this ignore ordinal case?
      if (!instrument.meter.name.startsWith(prefix) ||
          !instrument.meter.name.endsWith(suffix)) {
        return false;
      }
    }
    return true;
  }

  static bool _isMoreSpecific(
    InstrumentRule rule,
    InstrumentRule? best,
    bool isLocalScope,
  ) {
    if (best == null) {
      return true;
    }

    // Listener name
    if (!string.isNullOrEmpty(rule.listenerName) &&
        !string.isNullOrEmpty(best.listenerName)) {
      return true;
    } else if (string.isNullOrEmpty(rule.listenerName) &&
        !string.isNullOrEmpty(best.listenerName)) {
      return false;
    }

    // Meter name
    if (!string.isNullOrEmpty(rule.meterName)) {
      if (string.isNullOrEmpty(best.meterName)) {
        return true;
      }

      // Longer is more specific.
      if (rule.meterName!.length != best.meterName!.length) {
        return rule.meterName!.length > best.meterName!.length;
      }
    } else if (!string.isNullOrEmpty(best.meterName)) {
      return false;
    }

    // Instrument name
    if (!string.isNullOrEmpty(rule.instrumentName) &&
        string.isNullOrEmpty(best.instrumentName)) {
      return true;
    } else if (string.isNullOrEmpty(rule.instrumentName) &&
        !string.isNullOrEmpty(best.instrumentName)) {
      return false;
    }

    // Scope

    // Already matched as local
    if (isLocalScope) {
      // Local is more specific than Local+Global
      if (!rule.scopes.hasFlag(MeterScope.global) &&
          best.scopes.hasFlag(MeterScope.global)) {
        return true;
      } else if (rule.scopes.hasFlag(MeterScope.global) &&
          !best.scopes.hasFlag(MeterScope.global)) {
        return false;
      }
    } else {
      // Global is more specific than Local+Global
      if (!rule.scopes.hasFlag(MeterScope.local) &&
          best.scopes.hasFlag(MeterScope.local)) {
        return true;
      } else if (rule.scopes.hasFlag(MeterScope.local) &&
          !best.scopes.hasFlag(MeterScope.local)) {
        return false;
      }
    }

    // All things being equal, take the last one.
    return true;
  }

  @override
  void recordObservableInstruments() => throw Exception();

  @override
  void dispose() {
    _disposing = true;
    _disposed = true;
    _meterListener.dispose();
    _disposing = false;
  }
}
