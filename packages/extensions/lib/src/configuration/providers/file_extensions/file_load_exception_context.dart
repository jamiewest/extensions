import 'file_configuration_provider.dart';

/// Contains information about a file load exception.
class FileLoadExceptionContext {
  /// Gets or sets the [FileConfigurationProvider] that caused the exception.
  late FileConfigurationProvider provider;

  /// Gets or sets the exception that occurred in Load.
  late Exception exception;

  /// Gets or sets a value that indicates whether the exception is rethrown.
  ///
  /// `true` if the exception isn't rethrown; otherwise, `false`.
  bool ignore = false;
}
