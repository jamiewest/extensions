import '../../hosting.dart';
import '../common/cancellation_token.dart';
import 'host_defaults.dart' as host_defaults;
import 'host_options.dart';
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
    hostConfigBuilder.addInMemoryCollection(
      [MapEntry<String, String>(HostDefaults.contentRootKey, '')],
    );

    // hostConfigBuilder.AddEnvironmentVariables(prefix: "DOTNET_");

    if (args != null) {
      if (args.isNotEmpty) {
        hostConfigBuilder.addCommandLine(args);
      }
    }
  }

  static void addDefaultServices(
    HostBuilderContext hostingContext,
    ServiceCollection services,
  ) {
    services.addLogging(
      (logging) => logging.addDebug(),
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
