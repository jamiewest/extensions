import 'dart:async';

import '../shared/cancellation_token.dart';
import '../shared/disposable.dart';
import 'hosted_service.dart';

/// Base class for implementing a long running [HostedService].
abstract class BackgroundService implements HostedService, Disposable {
  Future? _executeFuture;
  CancellationTokenSource? _stoppingCts;

  /// Gets the Future that executes the background operation.
  Future<void> get executeFuture => _executeFuture!;

  /// This method is called when the [HostedService] starts. The
  /// implementation should return a task that represents the
  /// lifetime of the long running operation(s) being performed.
  Future<void> execute(CancellationToken stoppingToken);

  /// Triggered when the application host is ready to start the service.
  @override
  Future<void> start(CancellationToken cancellationToken) async {
    // Create linked token to allow cancelling executing
    // task from provided token
    _stoppingCts =
        CancellationTokenSource.createLinkedTokenSource([cancellationToken]);

    // Store the task we're executing
    _executeFuture = execute(_stoppingCts!.token);

    await _executeFuture;
  }

  /// Triggered when the application host is performing a graceful shutdown.
  @override
  Future<void> stop(CancellationToken cancellationToken) {
    // Stop called without start
    if (_executeFuture == null) {
      return Future.value(null);
    }

    try {
      // Signal cancellation to the executing method
      _stoppingCts!.cancel();
    } finally {}

    return Future.value(null);
  }

  @override
  void dispose() {
    _stoppingCts!.cancel();
  }
}
