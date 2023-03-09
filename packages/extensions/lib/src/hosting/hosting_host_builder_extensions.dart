import 'package:path/path.dart' as p;

import '../configuration/configuration_builder.dart';
import '../configuration/memory_configuration_builder_extensions.dart';
import '../dependency_injection/default_service_provider_factory.dart';
import '../dependency_injection/service_provider.dart';
import '../dependency_injection/service_provider_options.dart';
import '../logging/logging_builder.dart';
import '../logging/providers/debug/debug_logger_factory_extensions.dart';
import '../options/options_service_collection_extensions.dart';
import 'host.dart';
import 'host_builder.dart';
import 'host_builder_context.dart';
import 'host_defaults.dart' as host_defaults;
import 'host_environment_env_extensions.dart';
import 'host_options.dart';

typedef ConfigureDefaultServiceProvider = void Function(
  HostBuilderContext context,
  ServiceProviderOptions options,
);

extension HostingHostBuilderExtensions on HostBuilder {
  /// Specify the environment to be used by the host.
  ///
  /// To avoid the environment being overwritten by a default
  /// value, ensure this is called after defaults are configured.
  HostBuilder useEnvironment(String environment) => configureHostConfiguration(
        (configBuilder) => configBuilder.addInMemoryCollection(
          [
            MapEntry<String, String>(
              host_defaults.environmentKey,
              environment,
            )
          ],
        ),
      );

  /// Specify the content root directory to be used by the host.
  ///
  /// To avoid the content root directory being overwritten by a default value,
  /// this is called after defaults are configured.
  HostBuilder useContentRoot(String contentRoot) => configureHostConfiguration(
        (configBuilder) => configBuilder.addInMemoryCollection([
          MapEntry<String, String>(
            host_defaults.contentRootKey,
            contentRoot,
          )
        ]),
      );

  /// Specify the [ServiceProvider] to be the default one.
  HostBuilder useDefaultServiceProvider(
    ConfigureDefaultServiceProvider configure,
  ) =>
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
    void Function(
      HostBuilderContext context,
      LoggingBuilder logging,
    )
        configure,
  ) =>
      configureServices(
        (context, collection) => collection.addLogging(
          (builder) => configure(context, builder),
        ),
      );

  /// Adds a delegate for configuring the [HostOptions] of the [Host].
  HostBuilder configureHostOptions(
    void Function(
      HostBuilderContext context,
      HostOptions options,
    )
        configureOptions,
  ) =>
      configureServices(
        (context, collection) => collection.configure<HostOptions>(
          HostOptions.new,
          (h) => configureOptions(context, h),
        ),
      );

  /// Configures an existing [HostBuilder] instance with pre-configured
  /// defaults.
  HostBuilder configureDefaults([List<String>? args]) => configureLogging(
        (context, logging) => logging.addDebug(),
      ).configureAppConfiguration(
        (context, configuration) =>
            applyDefaultHostConfiguration(configuration),
      )..useServiceProviderFactory(
          factory: (context) => DefaultServiceProviderFactory(
            options: createDefaultServiceProviderOptions(context),
          ),
        );

  static void applyDefaultHostConfiguration(
    ConfigurationBuilder hostConfigBuilder,
  ) {
    setDefaultContentRoot(hostConfigBuilder);
  }

  static void setDefaultContentRoot(
    ConfigurationBuilder hostConfigBuilder,
  ) {
    var cwd = p.current;
    hostConfigBuilder.addInMemoryCollection(
      <String, String>{
        host_defaults.contentRootKey: cwd,
      }.entries,
    );
  }

  ServiceProviderOptions createDefaultServiceProviderOptions(
    HostBuilderContext context,
  ) {
    var isDevelopment = context.hostingEnvironment?.isDevelopment();
    return ServiceProviderOptions(
      validateScopes: isDevelopment!,
      validateOnBuild: isDevelopment!,
    );
  }
}
