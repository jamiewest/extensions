import '../shared/cancellation_token.dart';
import 'host.dart';
import 'host_application_lifetime.dart';

extension HostingAbstractionsHostExtensions on Host {
  Future<void> stop(Duration? timeout) async {
    // var cts = CancellationTokenSource(timeout);
    // await stop(cts.token);
  }

  Future<void> run([
    CancellationToken? token,
  ]) async {
    token ??= CancellationToken.none;
    try {
      await start(token);
      await waitForShutdown(token);
    } finally {
      // dispose
    }
  }

  Future<void> waitForShutdown([
    CancellationToken? token,
  ]) async {
    var applicationLifetime = services.getService<HostApplicationLifetime>();

    token ??= CancellationToken.none;

    token.register(
        (state) => (state as HostApplicationLifetime).stopApplication(),
        applicationLifetime);

    //await stop();
  }
}
