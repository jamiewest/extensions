import '../configuration/configuration_builder.dart';
import '../configuration/memory_configuration_builder_extensions.dart';
import '../configuration/providers/command_line/command_line_configuration_extensions.dart';
import '../dependency_injection/service_collection_service_extensions.dart';
import '../dependency_injection/service_provider_service_extensions.dart';
import '../logging/logger_factory.dart';
import '../options/options.dart';
import '../options/options_service_collection_extensions.dart';
import '../primitives/cancellation_token.dart';
import 'host_application_lifetime.dart';
import 'host_builder.dart';
import 'host_defaults.dart' as host_defaults;
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
  ) =>
      configureServices((_, collection) => collection
        ..addSingleton<HostLifetime, ConsoleLifetime>(
          (sp) => ConsoleLifetime(
            sp.getRequiredService<Options<ConsoleLifetimeOptions>>()
                as Options<ConsoleLifetimeOptions>,
            sp.getRequiredService<HostEnvironment>() as HostEnvironment,
            sp.getRequiredService<ApplicationLifetime>() as ApplicationLifetime,
            sp.getRequiredService<Options<HostOptions>>()
                as Options<HostOptions>,
            sp.getRequiredService<LoggerFactory>() as LoggerFactory,
          ),
        )
        ..configure<ConsoleLifetimeOptions>(
          ConsoleLifetimeOptions.new,
          (options) {
            options.suppressStatusMessages = false;
          },
        ));

  /// Enables console support, builds and starts the host, and waits for
  /// Ctrl+C or SIGTERM to shut down.
  Future<void> runConsole([CancellationToken? cancellationToken]) =>
      useConsoleLifetime((_) => {}).build().run(cancellationToken);
}

void applyDefaultHostConfiguration(
  ConfigurationBuilder hostConfigBuilder,
  List<String>? args,
) {
  hostConfigBuilder.addInMemoryCollection(
    [MapEntry<String, String>(host_defaults.contentRootKey, '')],
  );

  // hostConfigBuilder.AddEnvironmentVariables(prefix: "DOTNET_");

  if (args != null) {
    if (args.isNotEmpty) {
      hostConfigBuilder.addCommandLine(args);
    }
  }
}
