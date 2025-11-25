import 'package:extensions/hosting.dart';
import 'package:extensions/logging.dart';
import 'package:flutter/widgets.dart';

/// Allows consumers to be notified of application lifetime events.
class FlutterApplicationLifetime extends ApplicationLifetime {
  final Logger _logger;
  final _pausedSource = <VoidCallback>[];
  final _resumedSource = <VoidCallback>[];
  final _inactiveSource = <VoidCallback>[];
  final _detachedSource = <VoidCallback>[];
  final _hiddenSource = <VoidCallback>[];

  FlutterApplicationLifetime(Logger logger)
      : _logger = logger,
        super(logger);

  /// Triggered when the application host has paused.
  List<VoidCallback> get applicationPaused => _pausedSource;

  /// Triggered when the application host has resumed.
  List<VoidCallback> get applicationResumed => _resumedSource;

  /// Triggered when the application host is inactive.
  List<VoidCallback> get applicationInactive => _inactiveSource;

  /// Triggered when the application host is detached.
  List<VoidCallback> get applicationDetached => _detachedSource;

  /// Triggered when the application host is hidden.
  List<VoidCallback> get applicationHidden => _hiddenSource;

  void notifyPaused() {
    try {
      _executeHandlers(_pausedSource);
    } on Exception catch (ex) {
      _logger.logCritical(
        'An error occurred pausing the application',
        error: ex,
      );
    }
  }

  void notifyResumed() {
    try {
      _executeHandlers(_resumedSource);
    } on Exception catch (ex) {
      _logger.logCritical(
        'An error occurred resuming the application',
        error: ex,
      );
    }
  }

  void notifyInactive() {
    try {
      _executeHandlers(_inactiveSource);
    } on Exception catch (ex) {
      _logger.logCritical(
        'An error occurred while the application was inactive',
        error: ex,
      );
    }
  }

  void notifyDetached() {
    try {
      _executeHandlers(_detachedSource);
    } on Exception catch (ex) {
      _logger.logCritical(
        'An error occurred detaching the application',
        error: ex,
      );
    }
  }

  void notifyHidden() {
    try {
      _executeHandlers(_hiddenSource);
    } on Exception catch (ex) {
      _logger.logCritical(
        'An error occurred hiding the application',
        error: ex,
      );
    }
  }

  void _executeHandlers(Iterable<VoidCallback> handlers) {
    for (var handler in handlers.toList().reversed) {
      handler.call();
    }
  }
}
