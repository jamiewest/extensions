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
/// ```dart
/// final host = createDefaultBuilder(args)
///   ..configureServices((context, services) {
///     services.addSingleton<MyService>();
///   })
///   .build();
///
/// await host.run();
/// ```
///
/// ## Background Services
///
/// Run long-lived background tasks:
///
/// ```dart
/// class MyBackgroundService extends BackgroundService {
///   @override
///   Future<void> executeAsync(CancellationToken stoppingToken) async {
///     while (!stoppingToken.isCancellationRequested) {
///       // Do background work
///       await Future.delayed(Duration(seconds: 10));
///     }
///   }
/// }
///
/// services.addHostedService<MyBackgroundService>();
/// ```
///
/// ## Application Lifetime
///
/// React to application lifecycle events:
///
/// ```dart
/// final lifetime = host.services
///   .getRequiredService<HostApplicationLifetime>();
///
/// lifetime.applicationStarted.register(() {
///   print('Application started');
/// });
///
/// lifetime.applicationStopping.register(() {
///   print('Application is shutting down');
/// });
/// ```
///
/// ## Host Configuration
///
/// Configure the application environment and settings:
///
/// ```dart
/// final host = createApplicationBuilder()
///   ..environment.environmentName = 'Production'
///   ..configuration.addJsonFile('appsettings.json')
///   ..services.addLogging()
///   .build();
/// ```
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
