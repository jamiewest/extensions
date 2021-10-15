import 'dart:async';

import 'package:async/async.dart';

import '../shared/cancellation_token.dart';
import '../shared/disposable.dart';
import 'hosted_service.dart';

/// Base class for implementing a long running [HostedService].
abstract class BackgroundService implements HostedService, Disposable {
  CancelableOperation? _executeOperation;
  CancellationTokenSource? _stoppingCts;

  /// Gets the [CancelableOperation] that executes the background operation.
  CancelableOperation? get executeOperation => _executeOperation;

  /// This method is called when the [HostedService] starts. The
  /// implementation should return a future that represents the
  /// lifetime of the long running operation(s) being performed.
  Future<void> execute(CancellationToken stoppingToken);

  /// Triggered when the application host is ready to start the service.
  @override
  Future<void> start(CancellationToken cancellationToken) async {
    // Create linked token to allow cancelling executing
    // task from provided token
    _stoppingCts =
        CancellationTokenSource.createLinkedTokenSource([cancellationToken]);

    // Store the operation we're executing
    _executeOperation = CancelableOperation.fromFuture(
      execute(_stoppingCts!.token),
    );

    // If the operation is completed then return it, this will bubble
    // cancellation and failure to the caller
    if (_executeOperation != null) {
      if (_executeOperation!.isCompleted) {
        return _executeOperation!.value;
      }
    }

    // Otherwise it's running
    return Future.value(null);
  }

  /// Triggered when the application host is performing a graceful shutdown.
  @override
  Future<void> stop(CancellationToken cancellationToken) async {
    // Stop called without start
    if (_executeOperation == null) {
      return Future.value(null);
    }

    try {
      // Signal cancellation to the executing method
      _stoppingCts!.cancel();
    } finally {
      // Wait until the future completes or the stop token triggers
      var c = Completer();
      cancellationToken.register((o) {
        c.complete();
      });

      await Future.any([
        _executeOperation!.value,
        c.future,
      ]);
    }
  }

  @override
  void dispose() {
    _stoppingCts!.cancel();
  }
}
