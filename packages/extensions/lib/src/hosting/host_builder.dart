import 'package:path/path.dart' as p;

import '../../configuration.dart';
import '../../dependency_injection.dart';
import '../dependency_injection/default_service_provider_factory.dart';
import '../logging/logger_factory.dart';
import '../logging/logging_builder.dart';
import '../options/options.dart';
import '../options/options_service_collection_extensions.dart';
import 'environments.dart';
import 'host.dart';
import 'host_application_lifetime.dart';
import 'host_builder_context.dart';
import 'host_defaults.dart' as host_defaults;
import 'host_environment.dart';
import 'host_lifetime.dart';
import 'host_options.dart';
import 'internal/application_lifetime.dart';
import 'internal/configure_container_adapter.dart';
import 'internal/hosting_environment.dart';
import 'internal/null_lifetime.dart';
import 'internal/service_factory_adapter.dart';

typedef ConfigureServicesDelegate = void Function(
  HostBuilderContext context,
  ServiceCollection services,
);

typedef ConfigureAppConfigurationDelegate = void Function(
  HostBuilderContext context,
  ConfigurationBuilder configuration,
);

typedef ConfigureHostConfigurationDelegate = void Function(
  ConfigurationBuilder configuration,
);

typedef ServiceProviderFactoryDelegate<TContainerBuilder>
    = ServiceProviderFactory<TContainerBuilder> Function(
  HostBuilderContext? context,
);

typedef ConfigureContainerDelegate<TContainerBuilder> = TContainerBuilder
    Function(HostBuilderContext context, TContainerBuilder builder);

/// A program initialization abstraction.
class HostBuilder {
  final List<ConfigureHostConfigurationDelegate> _configureHostConfigActions =
      <ConfigureHostConfigurationDelegate>[];
  final List<ConfigureAppConfigurationDelegate> _configureAppConfigActions =
      <ConfigureAppConfigurationDelegate>[];
  final List<ConfigureServicesDelegate> _configureServicesActions =
      <ConfigureServicesDelegate>[];
  final List<ConfigureContainerAdapter> _configureContainerActions =
      <ConfigureContainerAdapter>[];

  IServiceFactoryAdapter? _serviceProviderFactory =
      ServiceFactoryAdapter<ServiceCollection>(
    DefaultServiceProviderFactory(),
  );

  bool _hostBuilt = false;
  Configuration? _hostConfiguration;
  Configuration? _appConfiguration;
  HostBuilderContext? _hostBuilderContext;
  HostEnvironment? _hostingEnvironment;
  ServiceProvider? _appServices;

  /// A central location for sharing state between components during
  /// the host building process.
  Map<dynamic, dynamic> get properties => <dynamic, dynamic>{};

  /// Set up the configuration for the builder itself. This will be used to
  /// initialize the [HostEnvironment] for use later in the build process.
  /// This can be called multiple times and the results will be additive.
  // ignore: avoid_returning_this
  HostBuilder configureHostConfiguration(
    ConfigureHostConfigurationDelegate configureDelegate,
  ) {
    _configureHostConfigActions.add(configureDelegate);
    return this;
  }

  /// Sets up the configuration for the remainder of the build
  /// process and application. This can be called multiple times and
  /// the results will be additive. The results will be available at
  /// `Configuration` for subsequent operations, as well as in `services`.
  // ignore: avoid_returning_this
  HostBuilder configureAppConfiguration(
    ConfigureAppConfigurationDelegate configureDelegate,
  ) {
    _configureAppConfigActions.add(configureDelegate);
    return this;
  }

  /// Adds services to the container. This can be called multiple
  /// times and the results will be additive.
  // ignore: avoid_returning_this
  HostBuilder configureServices(
    ConfigureServicesDelegate configureDelegate,
  ) {
    _configureServicesActions.add(configureDelegate);
    return this;
  }

  /// Overrides the factory used to create the service provider.
  // ignore: avoid_returning_this
  HostBuilder useServiceProviderFactory<TContainerBuilder>({
    ServiceProviderFactory<TContainerBuilder>? implementation,
    FactoryResolver<TContainerBuilder>? factory,
  }) {
    if (implementation != null) {
      _serviceProviderFactory =
          ServiceFactoryAdapter<TContainerBuilder>(implementation);
    } else {
      if (factory != null && _hostBuilderContext != null) {
        _serviceProviderFactory = ServiceFactoryAdapter.builder(
          () => _hostBuilderContext!,
          factory,
        );
      }
    }

    return this;
  }

  /// Enables configuring the instantiated dependency container.
  /// This can be called multiple times and
  /// the results will be additive.
  // ignore: avoid_returning_this
  HostBuilder configureContainer<TContainerBuilder>(
    ConfigureContainerAdapterDelegate<TContainerBuilder> configureDelegate,
  ) {
    _configureContainerActions.add(
      ConfigureContainerAdapter<TContainerBuilder>(configureDelegate),
    );
    return this;
  }

  /// Run the given actions to initialize the host.
  /// This can only be called once.
  Host build() {
    if (_hostBuilt) {
      throw Exception('Build can only be called once.');
    }
    _hostBuilt = true;

    _initializeHostConfiguration();
    _initializeHostingEnvironment();
    _initializeHostBuilderContext();
    _initializeAppConfiguration();
    _initializeServiceProvider();

    // _buildHostConfiguration();
    // _createHostingEnvironment();
    // _createHostBuilderContext();
    // _buildAppConfiguration();
    // _createServiceProvider();

    return resolveHost(_appServices!);

    //return _appServices?.getRequiredService<Host>() as Host;
  }

  void _initializeHostConfiguration() {
    // Make sure there's some default storage since there are
    // no default providers
    var configBuilder = ConfigurationBuilder().addInMemoryCollection();

    for (var buildAction in _configureHostConfigActions) {
      buildAction(configBuilder);
    }
    _hostConfiguration = configBuilder.build();
  }

  void _initializeHostingEnvironment() {
    _hostingEnvironment = createHostingEnvironment(_hostConfiguration!);
  }

  void _initializeHostBuilderContext() {
    _hostBuilderContext = HostBuilderContext(properties)
      ..hostingEnvironment = _hostingEnvironment!
      ..configuration = _hostConfiguration!;
  }

  void _initializeAppConfiguration() {
    var configBuilder = ConfigurationBuilder()
      ..addConfiguration(_hostConfiguration!, true);

    for (var buildAction in _configureAppConfigActions) {
      buildAction(_hostBuilderContext!, configBuilder);
    }

    _appConfiguration = configBuilder.build();
    _hostBuilderContext!.configuration = _appConfiguration;
  }

  void _initializeServiceProvider() {
    var services = ServiceCollection();

    populateServiceCollection(
      services,
      _hostBuilderContext!,
      _hostingEnvironment!,
      _appConfiguration!,
      () => _appServices!,
    );

    for (var configureServicesAction in _configureServicesActions) {
      configureServicesAction(_hostBuilderContext!, services);
    }

    var containerBuilder = _serviceProviderFactory?.createBuilder(services);
    if (containerBuilder != null) {
      for (var containerAction in _configureContainerActions) {
        containerAction.configureContainer(
          _hostBuilderContext!,
          containerBuilder,
        );
      }
    }

    _appServices =
        _serviceProviderFactory?.createServiceProvider(containerBuilder!);
  }
}

void populateServiceCollection(
  ServiceCollection services,
  HostBuilderContext hostBuilderContext,
  HostEnvironment hostingEnvironment,
  Configuration appConfiguration,
  ServiceProvider Function() serviceProviderGetter,
) {
  services
    ..addSingleton<HostEnvironment>(
      implementationInstance: hostingEnvironment,
    )
    ..addSingleton<HostBuilderContext>(
      implementationInstance: hostBuilderContext,
    )
    ..addSingleton<Configuration>(
      implementationInstance: appConfiguration,
    )
    ..addSingleton<ApplicationLifetime>(
      implementationFactory: (s) =>
          s.getService<HostApplicationLifetime>() as ApplicationLifetime,
    )
    ..addSingleton<HostApplicationLifetime>(
      implementationFactory: (s) => ApplicationLifetime(
        s.getService<LoggerFactory>().createLogger('ApplicationLifetime'),
      ),
    )
    ..addSingleton<HostLifetime>(implementationFactory: (s) => NullLifetime())
    ..tryAdd(
      ServiceDescriptor.singleton<Host>(
        implementationFactory: (_) {
          var appServices = serviceProviderGetter();

          return Host(
            appServices,
            appServices.getRequiredService<HostApplicationLifetime>(),
            appServices
                .getRequiredService<LoggerFactory>()
                .createLogger('Host'),
            appServices.getRequiredService<HostLifetime>(),
            appServices.getRequiredService<Options<HostOptions>>(),
          );
        },
      ),
    )
    ..configure<HostOptions>(HostOptions.new, (options) {
      options.initialize(hostBuilderContext.configuration!);
    })
    ..addLogging();
}

HostEnvironment createHostingEnvironment(Configuration hostConfiguration) {
  var hostingEnvironment = HostingEnvironment()
    ..applicationName =
        hostConfiguration[host_defaults.applicationKey] ??= 'application'
    ..environmentName = hostConfiguration[host_defaults.environmentKey] ??
        Environments.production
    ..contentRootPath = resolveContentRootPath(
      hostConfiguration[host_defaults.contentRootKey],
      p.current,
    );

  return hostingEnvironment;
}

String resolveContentRootPath(String? contentRootPath, String basePath) {
  if (contentRootPath == null) {
    return basePath;
  }
  if (p.isRootRelative(contentRootPath)) {
    return contentRootPath;
  }
  return p.join(p.absolute(basePath), contentRootPath);
}

Host resolveHost(ServiceProvider serviceProvider) {
  // resolve configuration explicitly once to mark it as resolved within the
  // service provider, ensuring it will be properly disposed with the provider
  serviceProvider.getService<Configuration>();

  var host = serviceProvider.getRequiredService<Host>();

  return host;
}
