import 'service_provider.dart';

/// Options for configuring various behaviors of the default
/// [ServiceProvider] implementation.
class ServiceProviderOptions {
  ServiceProviderOptions({
    this.validateScopes = false,
    this.validateOnBuild = false,
  });

  /// `true` to perform check verifying that scoped services
  /// never gets resolved from root provider; otherwise `false`.
  /// Defaults to `false`.
  bool validateScopes;

  /// `true` to perform check verifying that all services can
  /// be created during `BuildServiceProvider` call; otherwise
  /// `false`. Defaults to `false`.
  bool validateOnBuild;
}
