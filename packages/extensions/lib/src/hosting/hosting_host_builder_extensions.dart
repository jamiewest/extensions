import '../configuration/configuration_builder.dart';
import '../configuration/memory_configuration_builder_extensions.dart';
import '../dependency_injection/default_service_provider_factory.dart';
import '../dependency_injection/service_collection.dart';
import '../dependency_injection/service_collection_service_extensions.dart';
import '../dependency_injection/service_provider_options.dart';
import '../dependency_injection/service_provider_service_extensions.dart';
import '../logging/logger_factory.dart';
import '../logging/logging_builder.dart';
import '../logging/providers/debug/debug_logger_factory_extensions.dart';
import '../options/options.dart';
import '../options/options_service_collection_extensions.dart';
import 'host.dart';
import 'host_builder.dart';
import 'host_builder_context.dart';
import 'host_defaults.dart';
import 'host_environment.dart';
import 'host_lifetime.dart';
import 'host_options.dart';
import 'internal/application_lifetime.dart';
import 'internal/console_lifetime.dart';
import 'internal/console_lifetime_options.dart';

extension HostingHostBuilderExtensions on HostBuilder {
  /// Specify the environment to be used by the host.
  HostBuilder useEnvironment(String environment) => configureHostConfiguration(
        (configBuilder) => configBuilder.addInMemoryCollection(
          [MapEntry<String, String>(HostDefaults.environmentKey, environment)],
        ),
      );

  /// Specify the content root directory to be used by the host.
  HostBuilder useContentRoot(String contentRoot) => configureHostConfiguration(
        (configBuilder) => configBuilder.addInMemoryCollection([
          MapEntry<String, String>(HostDefaults.contentRootKey, contentRoot)
        ]),
      );

  /// Specify the `ServiceProvider` to be the default one.
  HostBuilder useDefaultServiceProvider(
          Function(HostBuilderContext context, ServiceProviderOptions options)
              configure) =>
      useServiceProviderFactory(
        factory: (context) {
          var options = ServiceProviderOptions();
          configure(context, options);
          return DefaultServiceProviderFactory(options: options);
        },
      );

  /// Adds a delegate for configuring the provided [LoggingBuilder].
  /// This may be called multiple times.
  HostBuilder configureLogging(
    Function(HostBuilderContext context, LoggingBuilder logging)
        configureLogging,
  ) =>
      this.configureServices((context, collection) => collection.addLogging(
            (builder) => configureLogging(context, builder),
          ));

  /// Adds a delegate for configuring the [HostOptions] of the [Host].
  HostBuilder configureHostOptions(
          Function(HostBuilderContext context, HostOptions options)
              configureOptions) =>
      this.configureServices(
        (context, collection) => collection.configure<HostOptions>(
          () => HostOptions(),
          (h) => configureOptions(context, h),
        ),
      );

  /// Sets up the configuration for the remainder of the build process
  /// and application. This can be called multiple times and the results
  /// will be additive. The results will be available at
  /// `HostBuilderContext.Configuration` for subsequent operations, as
  /// well as in `Host.Services`.
  HostBuilder configureAppConfiguration(
    Function(ConfigurationBuilder builder) configureDelegate,
  ) =>
      this.configureAppConfiguration(
          (context, builder) => configureDelegate(builder));

  /// Adds services to the container. This can be called multiple times
  /// and the results will be additive.
  HostBuilder configureServices(
          Function(ServiceCollection collection) configureDelegate) =>
      this.configureServices(
          (context, collection) => configureDelegate(collection));

  /// Enables configuring the instantiated dependency container. This can be
  /// called multiple times and the results will be additive.
  HostBuilder configureContainer<TContainerBuilder>(
    Function(TContainerBuilder b) configureDelegate,
  ) =>
      this.configureContainer<TContainerBuilder>(
          (context, builder) => configureDelegate(builder));

  /// Configures an existing <see cref="IHostBuilder"/> instance with pre-configured defaults.
  // ignore: prefer_expression_function_bodies
  HostBuilder configureDefaults([List<String>? args]) {
    configureLogging((context, logging) => logging.addDebug());
    return this;
  }

  HostBuilder useConsoleLifetime([ConsoleLifetimeOptions? options]) =>
      configureServices(
        (collection) {
          collection
              .addSingleton<HostLifetime>(
            implementationFactory: (s) => ConsoleLifetime(
              s.getRequiredService<Options<ConsoleLifetimeOptions>>(),
              s.getRequiredService<HostEnvironment>(),
              s.getRequiredService<ApplicationLifetime>(),
              s.getRequiredService<Options<HostOptions>>(),
              s.getRequiredService<LoggerFactory>(),
            ),
          )
              .configure<ConsoleLifetimeOptions>(
            () => ConsoleLifetimeOptions(),
            (options) {
              options.suppressStatusMessages = false;
            },
          );
        },
      );
}
