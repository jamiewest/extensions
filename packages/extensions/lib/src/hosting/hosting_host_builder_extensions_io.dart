import '../configuration/configuration_builder.dart';
import '../configuration/memory_configuration_builder_extensions.dart';
import '../configuration/providers/command_line/command_line_configuration_extensions.dart';
import '../configuration/providers/environment_variables/environment_variables_extensions.dart';
import '../configuration/providers/file_extensions/file_configuration_extensions.dart';
import '../configuration/providers/json/json_configuration_extensions.dart';
import '../dependency_injection/service_collection.dart';
import '../dependency_injection/service_collection_service_extensions.dart';
import '../dependency_injection/service_provider_options.dart';
import '../dependency_injection/service_provider_service_extensions.dart';
import '../logging/logger_factory.dart';
import '../logging/logger_filter_options.dart';
import '../logging/logging_builder.dart';
import '../logging/providers/configuration/logging_configuration.dart';
import '../logging/providers/debug/debug_logger_factory_extensions.dart';
import '../options/options.dart';
import '../options/options_service_collection_extensions.dart';
import '../system/threading/cancellation_token.dart';
import 'host_application_lifetime.dart';
import 'host_builder.dart';
import 'host_builder_context.dart';
import 'host_defaults.dart';
import 'host_environment.dart';
import 'host_environment_env_extensions.dart';
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
  HostBuilder useConsoleLifetime([
    void Function(ConsoleLifetimeOptions options)? configure,
  ]) =>
      configureServices(
        (_, collection) => collection
          ..addSingleton<HostLifetime>(
            (sp) => ConsoleLifetime(
              sp.getRequiredService<Options<ConsoleLifetimeOptions>>(),
              sp.getRequiredService<HostEnvironment>(),
              sp.getRequiredService<ApplicationLifetime>(),
              sp.getRequiredService<Options<HostOptions>>(),
              sp.getRequiredService<LoggerFactory>(),
            ),
          )
          ..configure<ConsoleLifetimeOptions>(
            ConsoleLifetimeOptions.new,
            (options) {
              options.suppressStatusMessages = false;
            },
          ),
      );

  /// Enables console support, builds and starts the host, and waits for
  /// Ctrl+C or SIGTERM to shut down.
  Future<void> runConsole([CancellationToken? cancellationToken]) =>
      useConsoleLifetime((_) => {}).build().run(cancellationToken);

  static void applyDefaultHostConfiguration(
    ConfigurationBuilder hostConfigBuilder,
    List<String>? args,
  ) {
    hostConfigBuilder
      ..addInMemoryCollection(
        [MapEntry<String, String>(HostDefaults.contentRootKey, '')],
      )
      ..addEnvironmentVariables('DOTNET_');

    if (args != null && args.isNotEmpty) {
      hostConfigBuilder.addCommandLine(args);
    }
  }

  static void applyDefaultAppConfiguration(
    HostBuilderContext hostingContext,
    ConfigurationBuilder appConfigBuilder,
    List<String>? args,
  ) {
    var env = hostingContext.hostingEnvironment!;
    var reloadOnChangeConfig =
        hostingContext.configuration!['hostBuilder:reloadConfigOnChange'];
    var reloadOnChange = reloadOnChangeConfig == 'true';

    appConfigBuilder
      ..setBasePath(env.contentRootPath)
      ..addJson(
        'appsettings.json',
        optional: true,
        reloadOnChange: reloadOnChange,
      )
      ..addJson(
        'appsettings.${env.environmentName}.json',
        optional: true,
        reloadOnChange: reloadOnChange,
      )
      ..addEnvironmentVariables();

    if (env.isDevelopment() && env.applicationName.isNotEmpty) {
      // In development, optionally load user secrets if available
      // This would require additional user secrets implementation
    }

    if (args != null && args.isNotEmpty) {
      appConfigBuilder.addCommandLine(args);
    }
  }

  static void addDefaultServices(
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

  static ServiceProviderOptions createDefaultServiceProviderOptions(
    HostBuilderContext context,
  ) {
    final isDevelopment = context.hostingEnvironment!.isDevelopment();
    return ServiceProviderOptions(
      validateScopes: isDevelopment,
      validateOnBuild: isDevelopment,
    );
  }
}
