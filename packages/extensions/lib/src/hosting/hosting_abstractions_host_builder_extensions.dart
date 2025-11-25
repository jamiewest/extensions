import '../system/threading/cancellation_token.dart';
import 'host.dart';
import 'host_builder.dart';

/// Provides extension methods for the [HostBuilder] from the hosting
/// abstractions package.
extension HostingAbstractionsHostBuilderExtensions on HostBuilder {
  /// Builds and starts the host.
  Future<Host> start({
    CancellationToken? cancellationToken,
  }) async {
    var host = build();
    await host.start(cancellationToken);
    return host;
  }
}
