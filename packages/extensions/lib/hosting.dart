/// Provides classes for managing application lifetime, hosting
/// background services, and coordinating application startup/shutdown.
///
/// This library implements hosting abstractions inspired by
/// Microsoft.Extensions.Hosting, enabling structured application lifecycle
/// management with dependency injection integration.
///
/// ## Basic Application Host
///
/// Create and run a hosted application:
///
/// {@example /example/example.dart#default_host}
///
/// ## Background Services
///
/// Run long-lived background tasks by overriding [BackgroundService.execute]:
///
/// {@example /example/example_background_service.dart#background_service}
///
/// Register it like any other hosted service:
///
/// {@example /example/example_background_service.dart#register_background_service}
///
/// ## Application Lifetime
///
/// React to application lifecycle events:
///
/// {@example /example/example.dart#lifetime_callbacks}
///
/// ## Host Configuration
///
/// Build and start a host directly when the console lifetime is not needed:
///
/// {@example /example/example_hosting.dart#build_and_start_host}
///
library;

import 'src/hosting/host_application_builder.dart';
import 'src/hosting/host_application_builder_settings.dart';
import 'src/hosting/host_builder.dart';
import 'src/hosting/hosting_host_builder_extensions.dart';

export 'src/hosting/background_service.dart';
export 'src/hosting/environments.dart';
export 'src/hosting/host.dart';
export 'src/hosting/host_application_builder.dart';
export 'src/hosting/host_application_builder_settings.dart';
export 'src/hosting/host_application_lifetime.dart';
export 'src/hosting/host_builder.dart'
    hide
        createHostingEnvironment,
        populateServiceCollection,
        resolveContentRootPath,
        resolveHost;
export 'src/hosting/host_builder_context.dart';
export 'src/hosting/host_defaults.dart';
export 'src/hosting/host_environment.dart';
export 'src/hosting/host_environment_env_extensions.dart';
export 'src/hosting/host_lifetime.dart';
export 'src/hosting/hosted_service.dart';
export 'src/hosting/hosting_abstractions_host_builder_extensions.dart';
export 'src/hosting/hosting_abstractions_host_extensions.dart';
export 'src/hosting/hosting_host_builder_extensions.dart'
    hide addCommandLineConfig, setDefaultContentRoot;
export 'src/hosting/internal/application_lifetime.dart';
export 'src/hosting/internal/hosting_environment.dart';
export 'src/hosting/internal/service_factory_adapter.dart';
export 'src/hosting/service_collection_hosted_service_extensions.dart';
export 'src/options/options_builder_extensions.dart';

/// Initializes a new instance of the [HostBuilder] class with
/// pre-configured defaults.
HostBuilder createDefaultBuilder([List<String>? args]) {
  var builder = DefaultHostBuilder();
  return builder.configureDefaults(args);
}

HostApplicationBuilder createApplicationBuilder({
  HostApplicationBuilderSettings? settings,
}) =>
    HostApplicationBuilder(
      settings: settings,
    );
