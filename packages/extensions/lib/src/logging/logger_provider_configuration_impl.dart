import '../configuration/configuration.dart';
import 'i_logger_provider_configuration.dart';
import 'i_logger_provider_configuration_factory.dart';

/// Implementation of [ILoggerProviderConfiguration] that retrieves
/// configuration for a specific logger provider type.
///
/// This class acts as a bridge between the configuration factory and
/// logger providers, providing type-safe access to provider-specific
/// configuration.
///
/// Type parameter [T] represents the logger provider type.
class LoggerProviderConfigurationImpl<T>
    implements ILoggerProviderConfiguration<T> {
  final IConfiguration _configuration;

  /// Creates a new instance of [LoggerProviderConfigurationImpl].
  ///
  /// The [providerConfigurationFactory] is used to retrieve the
  /// configuration specific to the provider type [T].
  LoggerProviderConfigurationImpl(
    ILoggerProviderConfigurationFactory providerConfigurationFactory,
  ) : _configuration = providerConfigurationFactory.getConfiguration(T);

  @override
  IConfiguration get configuration => _configuration;
}
