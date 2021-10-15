import 'dart:collection';

import 'package:extensions/hosting.dart';
import 'package:extensions/logging.dart';

class FlutterApplicationLifetime extends ApplicationLifetime {
  final Logger _logger;
  final _pausedSource = _LifecycleRegister();
  final _resumedSource = _LifecycleRegister();
  final _inactiveSource = _LifecycleRegister();
  final _detachedSource = _LifecycleRegister();

  FlutterApplicationLifetime(Logger logger)
      : _logger = logger,
        super(logger);

  _LifecycleRegister get applicationPaused => _pausedSource;

  _LifecycleRegister get applicationResumed => _resumedSource;

  _LifecycleRegister get applicationInactive => _inactiveSource;

  _LifecycleRegister get applicationDetached => _detachedSource;

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

  void _executeHandlers(_LifecycleRegister register) {
    // Run the cancellation token callbacks
    register.notify();
  }
}

class _LifecycleRegister {
  final HashSet<Function> _callbacks = HashSet<Function>();
  void register(Function callback) {
    _callbacks.add(callback);
  }

  void notify() {
    for (var callback in _callbacks) {
      callback.call();
    }
  }
}
