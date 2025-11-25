part of '../../diagnostics.dart';

class MetricsSubscriptionManager implements Disposable {
  late final List<ListenerSubscription> _listeners;
  Disposable? _changeTokenRegistration;
  bool _disposed = false;

  MetricsSubscriptionManager(
    Iterable<MetricsListener> listeners,
    OptionsMonitor<MetricsOptions> options,
    MeterFactory meterFactory,
  ) {
    //var list = listeners.toList();
    _listeners = <ListenerSubscription>[];
    for (var listener in listeners) {
      _listeners.add(ListenerSubscription(listener, meterFactory));
    }
    _changeTokenRegistration = options.onChange(_updateRules);
    _updateRules(options.currentValue);
  }

  void initialize() {
    for (var listener in _listeners) {
      listener.initialize();
    }
  }

  void _updateRules(MetricsOptions options, [String? name]) {
    if (_disposed) {
      return;
    }

    var rules = options.rules;

    for (var listener in _listeners) {
      listener._updateRules(rules);
    }
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }

    _disposed = true;
    _changeTokenRegistration?.dispose();
    for (var listener in _listeners) {
      listener.dispose();
    }
  }
}
