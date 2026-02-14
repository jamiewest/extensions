import 'package:flutter/widgets.dart';

import '../extensions_flutter.dart';

/// Widget used to monitor lifecycle event changes
class FlutterLifecycleObserver extends StatefulWidget {
  const FlutterLifecycleObserver({
    super.key,
    required this.child,
    required this.lifetime,
  });

  /// The [child] contained by this object.
  final Widget child;

  final FlutterApplicationLifetime lifetime;

  @override
  State<StatefulWidget> createState() => _FlutterLifecycleObserver();
}

class _FlutterLifecycleObserver extends State<FlutterLifecycleObserver>
    with WidgetsBindingObserver {
  late final AppLifecycleListener _listener;

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listener = AppLifecycleListener();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _listener.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        widget.lifetime.notifyPaused();
        break;
      case AppLifecycleState.resumed:
        widget.lifetime.notifyResumed();
        break;
      case AppLifecycleState.inactive:
        widget.lifetime.notifyInactive();
        break;
      case AppLifecycleState.detached:
        widget.lifetime.notifyDetached();
        break;
      case AppLifecycleState.hidden:
        widget.lifetime.notifyHidden();
        break;
    }
  }
}
