import 'package:extensions/annotations.dart';

import '../../dependency_injection/service_provider.dart';
import '../empty_service_provider.dart';
import 'hosted_file_client.dart';

/// A factory that creates a [HostedFileClient] from a [ServiceProvider].
typedef InnerHostedFileClientFactory = HostedFileClient Function(
    ServiceProvider services);

/// Builds a pipeline of [HostedFileClient] middleware.
///
/// This is an experimental feature.
@Source(
  name: 'HostedFileClientBuilder.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI/Files/',
)
class HostedFileClientBuilder {
  late final InnerHostedFileClientFactory _innerFactory;
  final List<HostedFileClient Function(HostedFileClient)> _factories = [];

  HostedFileClientBuilder._(InnerHostedFileClientFactory innerFactory)
      : _innerFactory = innerFactory;

  /// Creates a new [HostedFileClientBuilder] wrapping [innerClient].
  HostedFileClientBuilder(HostedFileClient innerClient) {
    _innerFactory = (_) => innerClient;
  }

  /// Creates a new [HostedFileClientBuilder] from a factory function.
  factory HostedFileClientBuilder.fromFactory(
          InnerHostedFileClientFactory innerFactory) =>
      HostedFileClientBuilder._(innerFactory);

  /// Adds a middleware factory to the pipeline.
  HostedFileClientBuilder use(
      HostedFileClient Function(HostedFileClient) factory) {
    _factories.add(factory);
    return this;
  }

  /// Builds the pipeline and returns the outermost [HostedFileClient].
  HostedFileClient build([ServiceProvider? services]) {
    services ??= EmptyServiceProvider.instance;
    var client = _innerFactory(services);
    for (var i = _factories.length - 1; i >= 0; i--) {
      client = _factories[i](client);
    }
    return client;
  }
}
