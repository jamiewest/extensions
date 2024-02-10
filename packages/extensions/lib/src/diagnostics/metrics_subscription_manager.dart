import 'package:extensions/src/diagnostics/listener_subscription.dart';

import '../common/disposable.dart';
import '../options/options_monitor.dart';
import 'meter_factory.dart';
import 'metrics_listener.dart';
import 'metrics_options.dart';

class MetricsSubscriptionManager implements Disposable {
  late final List<ListenerSubscription> _listeners;
  Disposable? _changeTokenRegistration;
  bool _disposed = false;

  MetricsSubscriptionManager(
    Iterable<MetricsListener> listeners,
    OptionsMonitor<MetricsOptions> options,
    MeterFactory meterFactory,
  ) {
    var list = listeners.toList();
    _listeners = <ListenerSubscription>[];
    for (var listener in listeners) {
      _listeners.add(ListenerSubscription(listener, meterFactory));
    }
    _changeTokenRegistration = options.onChange((options, [name]) {});
  }

  void initialize() {
    for (var listener in _listeners) {
      listener.initialize();
    }
  }

  void _updateRules(MetricsOptions options) {
    if (_disposed) {
      return;
    }

    var rules = options.rules;

    for (var listener in _listeners) {
      //listener.updateRules(rules);
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
