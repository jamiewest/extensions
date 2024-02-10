/// Hosting
///
/// To use, import `package:extensions/hosting.dart`.
/// {@category Hosting}
library extensions.hosting;

import 'src/hosting/host_application_builder.dart';
import 'src/hosting/host_application_builder_settings.dart';
import 'src/hosting/host_builder.dart';
import 'src/hosting/hosting_host_builder_extensions.dart';

export 'configuration.dart';
export 'dependency_injection.dart';
export 'logging.dart';
export 'options.dart';
export 'primitives.dart';
export 'src/hosting/background_service.dart';
export 'src/hosting/environments.dart';
export 'src/hosting/host.dart';
export 'src/hosting/host_application_builder.dart';
export 'src/hosting/host_application_builder_settings.dart';
export 'src/hosting/host_application_lifetime.dart';
export 'src/hosting/host_builder.dart';
export 'src/hosting/host_builder_context.dart';
export 'src/hosting/host_defaults.dart';
export 'src/hosting/host_environment.dart';
export 'src/hosting/host_environment_env_extensions.dart';
export 'src/hosting/host_lifetime.dart';
export 'src/hosting/hosted_service.dart';
export 'src/hosting/hosting_abstractions_host_builder_extensions.dart';
export 'src/hosting/hosting_abstractions_host_extensions.dart';
export 'src/hosting/hosting_host_builder_extensions.dart'
    show HostingHostBuilderExtensions;
export 'src/hosting/internal/application_lifetime.dart';
export 'src/hosting/internal/configure_container_adapter.dart';
export 'src/hosting/internal/hosting_environment.dart';
export 'src/hosting/internal/service_factory_adapter.dart';
export 'src/hosting/options_builder_extensions.dart';
export 'src/hosting/service_collection_hosted_service_extensions.dart';

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
