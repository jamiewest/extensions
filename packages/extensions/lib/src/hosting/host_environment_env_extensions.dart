import 'environments.dart';
import 'host_environment.dart';

/// Extension methods for [HostEnvironment].
extension HostEnvironmentEnvExtensions on HostEnvironment {
  /// Checks if the current host environment name is
  /// [Environments.development].
  bool isDevelopment() => isEnvironment(Environments.development);

  /// Checks if the current host environment
  /// name is [Environments.staging].
  bool isStaging() => isEnvironment(Environments.staging);

  /// Checks if the current host environment
  /// name is [Environments.production].
  bool isProduction() => isEnvironment(Environments.production);

  /// Compares the current host environment name against the specified value.
  bool isEnvironment(String environment) =>
      environmentName.toLowerCase() == environment.toLowerCase();
}
