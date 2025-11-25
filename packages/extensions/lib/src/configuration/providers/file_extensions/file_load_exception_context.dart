import 'file_configuration_provider.dart';

/// Contains information about a file load exception.
class FileLoadExceptionContext {
  /// The [FileConfigurationProvider] that caused the exception.
  FileConfigurationProvider? provider;

  /// The exception that occurred in Load.
  Exception? exception;

  /// If true, the exception will not be rethrown.
  bool ignore = false;
}
