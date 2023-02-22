import 'package:extensions/hosting.dart';

/// Allows consumers to be notified of application lifetime events.
class FlutterApplicationLifetime extends ApplicationLifetime {
  final Logger _logger;
  final _pausedSource = <Function()>[];
  final _resumedSource = <Function()>[];
  final _inactiveSource = <Function()>[];
  final _detachedSource = <Function()>[];

  FlutterApplicationLifetime(Logger logger)
      : _logger = logger,
        super(logger);

  /// Triggered when the application host has paused.
  List<Function()> get applicationPaused => _pausedSource;

  /// Triggered when the application host has resumed.
  List<Function()> get applicationResumed => _resumedSource;

  /// Triggered when the application host is inactive.
  List<Function()> get applicationInactive => _inactiveSource;

  /// Triggered when the application host is detached.
  List<Function()> get applicationDetached => _detachedSource;

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

  void _executeHandlers(Iterable<Function()> handlers) {
    for (var handler in handlers.toList().reversed) {
      handler.call();
    }
  }
}
