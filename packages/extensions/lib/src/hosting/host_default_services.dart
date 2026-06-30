import 'package:meta/meta.dart';

import '../dependency_injection/service_collection.dart';
import '../dependency_injection/service_provider_options.dart';
import '../logging/logger_filter_options.dart';
import '../logging/logging_builder.dart';
import '../logging/providers/configuration/logging_configuration.dart';
import '../logging/providers/debug/debug_logger_factory_extensions.dart';
import '../options/options_service_collection_extensions.dart';
import 'host_builder_context.dart';
import 'host_environment_env_extensions.dart';

/// Registers the default logging services applied by the host builders.
///
/// Web-safe: relies only on debug logging and configuration binding.
@internal
void addDefaultServices(
  HostBuilderContext hostingContext,
  ServiceCollection services,
) {
  services.addLogging(
    (logging) {
      logging
        ..services.configure<LoggerFilterOptions>(
          LoggerFilterOptions.new,
          (options) => LoggingConfiguration(
            hostingContext.configuration!,
          ).configure(options),
        )
        ..addDebug();
    },
  );
}

/// Builds the default [ServiceProviderOptions] applied by the host builders.
///
/// Validation is enabled in development environments.
@internal
ServiceProviderOptions createDefaultServiceProviderOptions(
  HostBuilderContext context,
) {
  final isDevelopment = context.hostingEnvironment!.isDevelopment();
  return ServiceProviderOptions(
    validateScopes: isDevelopment,
    validateOnBuild: isDevelopment,
  );
}
