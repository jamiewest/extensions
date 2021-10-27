import 'package:extensions/src/shared/cancellation_token.dart';

import '../dependency_injection/service_collection_service_extensions.dart';
import '../dependency_injection/service_provider_service_extensions.dart';
import '../logging/logger_factory.dart';
import '../options/options.dart';
import '../options/options_service_collection_extensions.dart';
import 'host_application_lifetime.dart';
import 'host_builder.dart';
import 'host_environment.dart';
import 'host_lifetime.dart';
import 'host_options.dart';
import 'hosting_abstractions_host_extensions.dart';
import 'internal/application_lifetime.dart';
import 'internal/console_lifetime.dart';
import 'internal/console_lifetime_options.dart';

extension HostingHostBuilderExtensions on HostBuilder {
  /// Listens for Ctrl+C or SIGTERM and calls
  /// [HostApplicationLifetime.stopApplication] to start the shutdown process.
  /// This will unblock extensions like RunAsync and WaitForShutdownAsync.
  HostBuilder useConsoleLifetime(
    void Function(ConsoleLifetimeOptions options)? configure,
  ) {
    return configureServices((_, collection) => collection
      ..addSingleton<HostLifetime>(
        implementationFactory: (sp) => ConsoleLifetime(
          sp.getRequiredService<Options<ConsoleLifetimeOptions>>(),
          sp.getRequiredService<HostEnvironment>(),
          sp.getRequiredService<ApplicationLifetime>(),
          sp.getRequiredService<Options<HostOptions>>(),
          sp.getRequiredService<LoggerFactory>(),
        ),
      )
      ..configure<ConsoleLifetimeOptions>(
        () => ConsoleLifetimeOptions(),
        (options) {
          options.suppressStatusMessages = false;
        },
      ));
  }

  /// Enables console support, builds and starts the host, and waits for
  /// Ctrl+C or SIGTERM to shut down.
  Future<void> runConsole([CancellationToken? cancellationToken]) =>
      useConsoleLifetime((_) => {}).build().run(cancellationToken);
}
