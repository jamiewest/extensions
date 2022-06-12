import 'dart:collection';

import 'package:extensions/hosting.dart';

class FlutterApplicationLifetime extends ApplicationLifetime {
  final Logger _logger;
  final _pausedSource = LifecycleRegister();
  final _resumedSource = LifecycleRegister();
  final _inactiveSource = LifecycleRegister();
  final _detachedSource = LifecycleRegister();

  FlutterApplicationLifetime(Logger logger)
      : _logger = logger,
        super(logger);

  LifecycleRegister get applicationPaused => _pausedSource;

  LifecycleRegister get applicationResumed => _resumedSource;

  LifecycleRegister get applicationInactive => _inactiveSource;

  LifecycleRegister get applicationDetached => _detachedSource;

  void notifyPaused() {
    try {
      _executeHandlers(_pausedSource);
    } on Exception catch (ex) {
      _logger.logCritical(
        'An error occurred pausing the application',
        exception: ex,
      );
    }
  }

  void notifyResumed() {
    try {
      _executeHandlers(_resumedSource);
    } on Exception catch (ex) {
      _logger.logCritical(
        'An error occurred resuming the application',
        exception: ex,
      );
    }
  }

  void notifyInactive() {
    try {
      _executeHandlers(_inactiveSource);
    } on Exception catch (ex) {
      _logger.logCritical(
        'An error occurred while the application was inactive',
        exception: ex,
      );
    }
  }

  void notifyDetached() {
    try {
      _executeHandlers(_detachedSource);
    } on Exception catch (ex) {
      _logger.logCritical(
        'An error occurred detaching the application',
        exception: ex,
      );
    }
  }

  void _executeHandlers(LifecycleRegister register) {
    // Run the cancellation token callbacks
    register.notify();
  }
}

typedef LifeCycleCallback = void Function();

class LifecycleRegister {
  final HashSet<LifeCycleCallback> _callbacks = HashSet<LifeCycleCallback>();
  void register(LifeCycleCallback callback) {
    _callbacks.add(callback);
  }

  void notify() {
    for (var callback in _callbacks.toList().reversed) {
      callback.call();
    }
  }
}
