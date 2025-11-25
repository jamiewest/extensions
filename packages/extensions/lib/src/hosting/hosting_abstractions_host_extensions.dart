import 'dart:async';

import '../dependency_injection/service_provider_service_extensions.dart';
import '../system/threading/cancellation_token.dart';
import 'host.dart';
import 'host_application_lifetime.dart';

extension HostingAbstractionsHostExtensions on Host {
  /// Runs an application and block the calling thread until host shutdown.
  void runSync() {
    run();
  }

  /// Runs an application and returns a [Future] that only completes when the
  /// token is triggered or shutdown is triggered.
  Future<void> run([
    CancellationToken? token,
  ]) async {
    token ??= CancellationToken.none;
    try {
      await start(token);
      await waitForShutdown(token);
    } finally {
      await disposeAsync();
    }
  }

  /// Returns a [Future] that completes when shutdown is triggered via the
  /// given token.
  Future<void> waitForShutdown([
    CancellationToken? token,
  ]) async {
    var applicationLifetime =
        services.getRequiredService<HostApplicationLifetime>();

    token ??= CancellationToken.none;

    token.register(
      (state) => (state as HostApplicationLifetime).stopApplication(),
      applicationLifetime,
    );

    var waitForStop = Completer<void>();
    applicationLifetime.applicationStopping.register(
      (state) {
        (state as Completer).complete();
      },
      waitForStop,
    );

    await waitForStop.future;

    // Host will use its default ShutdownTimeout if none is specified.
    // The cancellation token may have been triggered to unblock waitForStop.
    // Don't pass it here because that would trigger an abortive shutdown.
    await stop(CancellationToken.none);
  }
}
