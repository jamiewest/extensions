import 'package:extensions/hosting.dart';
import 'package:extensions/logging.dart';
import 'package:flutter/widgets.dart';

/// Manages Flutter-specific application lifecycle events.
///
/// Extends [ApplicationLifetime] to add Flutter lifecycle states:
/// paused, resumed, inactive, hidden, and detached.
///
/// Register callbacks by adding to the respective lists:
/// ```dart
/// lifetime.applicationPaused.add(() => saveState());
/// lifetime.applicationResumed.add(() => refreshData());
/// ```
///
/// Handlers are executed in reverse registration order (LIFO) to ensure
/// proper cleanup ordering. Errors in handlers are logged but do not
/// prevent other handlers from executing.
class FlutterApplicationLifetime extends ApplicationLifetime {
  final Logger _logger;
  final _pausedSource = <VoidCallback>[];
  final _resumedSource = <VoidCallback>[];
  final _inactiveSource = <VoidCallback>[];
  final _detachedSource = <VoidCallback>[];
  final _hiddenSource = <VoidCallback>[];

  FlutterApplicationLifetime(super.logger) : _logger = logger;

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

  /// Notifies all [applicationPaused] handlers that the app has been paused.
  ///
  /// Called by [FlutterLifecycleObserver] when the app enters the paused state.
  /// Handlers are executed in reverse registration order.
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

  /// Notifies all [applicationResumed] handlers that the app has resumed.
  ///
  /// Called by [FlutterLifecycleObserver] when the app returns to the foreground.
  /// Handlers are executed in reverse registration order.
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

  /// Notifies all [applicationInactive] handlers that the app is inactive.
  ///
  /// Called by [FlutterLifecycleObserver] when the app enters an inactive state
  /// (e.g., incoming phone call, app switcher). Handlers are executed in
  /// reverse registration order.
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

  /// Notifies all [applicationDetached] handlers that the app is detached.
  ///
  /// Called by [FlutterLifecycleObserver] when the app is detached from the
  /// Flutter engine. Handlers are executed in reverse registration order.
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

  /// Notifies all [applicationHidden] handlers that the app is hidden.
  ///
  /// Called by [FlutterLifecycleObserver] when the app is hidden from view.
  /// Handlers are executed in reverse registration order.
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

  /// Executes handlers in reverse order (LIFO).
  void _executeHandlers(Iterable<VoidCallback> handlers) {
    for (var handler in handlers.toList().reversed) {
      handler.call();
    }
  }
}
