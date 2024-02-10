/// Commonly used environment names.
class Environments {
  /// Specifies the Development environment.
  ///
  /// The development environment can enable features that shouldn't be
  /// exposed in production. Because of the performance cost, scope
  /// validation and dependency validation only happens in development.
  static String development = 'Development';

  /// Specifies the Staging environment.
  ///
  /// The staging environment can be used to validate app changes before
  /// changing the environment to production.
  static String staging = 'Staging';

  /// Specifies the Production environment.
  ///
  /// The production environment should be configured to maximize security,
  /// performance, and application robustness.
  static String production = 'Production';
}
