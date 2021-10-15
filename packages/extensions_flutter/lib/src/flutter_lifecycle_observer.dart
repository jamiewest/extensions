import 'package:flutter/widgets.dart';

import 'flutter_application_lifetime.dart';

/// Widget used to monitor lifecycle event changes
class FlutterLifecycleObserver extends StatefulWidget {
  const FlutterLifecycleObserver({
    Key? key,
    required this.child,
    required this.lifetime,
  }) : super(key: key);

  final Widget child;

  final FlutterApplicationLifetime lifetime;

  @override
  State<StatefulWidget> createState() => _FlutterLifecycleObserver();
}

class _FlutterLifecycleObserver extends State<FlutterLifecycleObserver>
    with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      widget.lifetime.notifyPaused();
    }

    if (state == AppLifecycleState.resumed) {
      widget.lifetime.notifyResumed();
    }

    if (state == AppLifecycleState.inactive) {
      widget.lifetime.notifyInactive();
    }

    if (state == AppLifecycleState.detached) {
      widget.lifetime.notifyDetached();
    }
  }
}
