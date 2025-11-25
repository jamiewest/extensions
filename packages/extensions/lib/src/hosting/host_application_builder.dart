import 'package:path/path.dart' as p;

import '../configuration/configuration_manager.dart';
import '../configuration/memory_configuration_builder_extensions.dart';
import '../dependency_injection/service_collection.dart';
import '../dependency_injection/service_collection_container_builder_extensions.dart';
import '../dependency_injection/service_provider.dart';
import '../dependency_injection/service_provider_factory.dart';
import '../dependency_injection/service_provider_options.dart';
import '../logging/logging_builder.dart';
import 'host.dart';
import 'host_application_builder_settings.dart';
import 'host_builder.dart';
import 'host_builder_context.dart';
import 'host_defaults.dart';
import 'host_environment.dart';
import 'hosting_host_builder_extensions_io.dart';
import 'internal/configure_container_adapter.dart';
import 'internal/service_factory_adapter.dart';

/// A builder for hosted applications and services which helps manage
/// configuration, logging, lifetime and more.
class HostApplicationBuilder {
  late final HostBuilderContext _hostBuilderContext;
  final ServiceCollection _serviceCollection = ServiceCollection();
  late final ServiceProvider Function() _createServiceProvider;
  late void Function(Object value) _configureContainer = (_) => {};
  HostBuilderAdapter? _hostBuilderAdapter;
  ServiceProvider? _appServices;
  bool _hostBuilt = false;
  late HostEnvironment _environment;
  late ConfigurationManager _configuration;
  late _LoggingBuilder _logging;

  HostApplicationBuilder({HostApplicationBuilderSettings? settings}) {
    var appSettings = settings ?? HostApplicationBuilderSettings();
    _configuration = appSettings.configuration ?? ConfigurationManager();

    if (!appSettings.disableDefaults) {
      HostingHostBuilderExtensions.applyDefaultHostConfiguration(
        configuration,
        appSettings.args,
      );
    }

    List<MapEntry<String, String>>? optionList;
    if (appSettings.applicationName != null) {
      optionList ??= <MapEntry<String, String>>[];
      optionList.add(
        MapEntry(HostDefaults.applicationKey, appSettings.applicationName!),
      );
    }
    if (appSettings.environmentName != null) {
      optionList ??= <MapEntry<String, String>>[];
      optionList.add(
        MapEntry(HostDefaults.environmentKey, appSettings.environmentName!),
      );
    }
    if (appSettings.configurationRootPath != null) {
      optionList ??= <MapEntry<String, String>>[];
      optionList.add(
        MapEntry(
            HostDefaults.contentRootKey, appSettings.configurationRootPath!),
      );
    }
    if (optionList != null) {
      configuration.addInMemoryCollection(optionList);
    }

    var hostingEnvironment = createHostingEnvironment(configuration);

    _hostBuilderContext = HostBuilderContext(<Object, Object>{})
      ..hostingEnvironment = hostingEnvironment
      ..configuration = configuration;

    _environment = hostingEnvironment;

    // Apply default app configuration (appsettings.json, environment
    // variables, command line)
    if (!appSettings.disableDefaults) {
      HostingHostBuilderExtensions.applyDefaultAppConfiguration(
        _hostBuilderContext,
        configuration,
        appSettings.args,
      );
    }

    populateServiceCollection(
      services,
      _hostBuilderContext,
      hostingEnvironment,
      configuration,
      () => _appServices!,
    );

    _logging = _LoggingBuilder(services);

    ServiceProviderOptions? serviceProviderOptions;

    if (!appSettings.disableDefaults) {
      HostingHostBuilderExtensions.addDefaultServices(
        _hostBuilderContext,
        services,
      );
      serviceProviderOptions =
          HostingHostBuilderExtensions.createDefaultServiceProviderOptions(
        _hostBuilderContext,
      );
    }

    _createServiceProvider = () {
      // Call _configureContainer in case anyone adds callbacks via
      // HostBuilderAdapter.ConfigureContainer<ServiceCollection>() during
      // build. Otherwise, this no-ops.
      _configureContainer(services);
      return serviceProviderOptions == null
          ? services.buildServiceProvider()
          : services.buildServiceProvider(serviceProviderOptions);
    };
  }

  /// Provides information about the hosting environment an application is
  /// running in.
  HostEnvironment get environment => _environment;

  /// A collection of services for the application to compose. This is useful
  /// for adding user provided or framework provided services.
  ConfigurationManager get configuration => _configuration;

  /// A collection of services for the application to compose. This is useful
  /// for adding user provided or framework provided services.
  ServiceCollection get services => _serviceCollection;

  /// A collection of logging providers for the application to compose. This is
  /// useful for adding new logging providers.
  LoggingBuilder get logging => _logging;

  /// Build the host. This can only be called once.
  Host build() {
    if (_hostBuilt) {
      throw Exception('Build can only be called once.');
    }
    _hostBuilt = true;

    _hostBuilderAdapter?.applyChanges();

    _appServices = _createServiceProvider();

    _serviceCollection.makeReadOnly();

    return resolveHost(_appServices!);
  }

  HostBuilder asHostBuilder() =>
      _hostBuilderAdapter ??= HostBuilderAdapter(this);
}

class HostBuilderAdapter implements HostBuilder {
  final HostApplicationBuilder _hostApplicationBuilder;
  final List<ConfigureHostConfigurationDelegate> _configureHostConfigActions =
      <ConfigureHostConfigurationDelegate>[];
  final List<ConfigureAppConfigurationDelegate> _configureAppConfigActions =
      <ConfigureAppConfigurationDelegate>[];
  final List<ConfigureServicesDelegate> _configureServicesActions =
      <ConfigureServicesDelegate>[];
  final List<ConfigureContainerAdapter<dynamic>> _configureContainerActions =
      <ConfigureContainerAdapter<dynamic>>[];

  IServiceFactoryAdapter? _serviceProviderFactory;

  HostBuilderAdapter(HostApplicationBuilder hostApplicationBuilder)
      : _hostApplicationBuilder = hostApplicationBuilder;

  void applyChanges() {
    var config = _hostApplicationBuilder.configuration;

    if (_configureHostConfigActions.isNotEmpty) {
      var previousApplicationName = config[HostDefaults.applicationKey];
      var previousEnvironment = config[HostDefaults.environmentKey];
      var previousContentRootConfig = config[HostDefaults.contentRootKey];
      var previousContentRootPath = _hostApplicationBuilder
          ._hostBuilderContext.hostingEnvironment?.contentRootPath;

      for (var configureHostAction in _configureHostConfigActions) {
        configureHostAction(config);
      }

      if (previousApplicationName != config[HostDefaults.applicationKey]) {
        throw Exception(
          'The application name changed from \'$previousApplicationName\''
          ' to \'$config[host_defaults.applicationKey]\'. Changing host'
          ' configuration is not supported.',
        );
      }
      if (previousEnvironment != config[HostDefaults.environmentKey]) {
        throw Exception(
          'The environment name changed from \'$previousEnvironment\' to'
          ' \'$config[host_defaults.environmentKey]\'. Changing host'
          ' configuration is not supported.',
        );
      }
      var currentContentRootConfig = config[HostDefaults.contentRootKey];
      if ((previousContentRootConfig != currentContentRootConfig) &&
          (previousContentRootPath !=
              resolveContentRootPath(currentContentRootConfig, p.current))) {
        throw Exception(
          'The content root changed from \'$previousContentRootConfig\' to'
          ' \'$currentContentRootConfig\'. Changing host configuration is'
          ' not supported.',
        );
      }
    }

    for (var configureAppAction in _configureAppConfigActions) {
      configureAppAction(_hostApplicationBuilder._hostBuilderContext, config);
    }
    for (var configureServicesAction in _configureServicesActions) {
      configureServicesAction(
        _hostApplicationBuilder._hostBuilderContext,
        _hostApplicationBuilder.services,
      );

      if (_configureContainerActions.isNotEmpty) {
        var previousConfigureContainer =
            _hostApplicationBuilder._configureContainer;

        _hostApplicationBuilder._configureContainer = (containerBuilder) {
          previousConfigureContainer(containerBuilder);

          for (var containerAction in _configureContainerActions) {
            containerAction.configureContainer(
              _hostApplicationBuilder._hostBuilderContext,
              containerBuilder,
            );
          }
        };
      }

      if (_serviceProviderFactory != null) {
        _hostApplicationBuilder._createServiceProvider = () {
          var containerBuilder = _serviceProviderFactory!
              .createBuilder(_hostApplicationBuilder.services);
          _hostApplicationBuilder._configureContainer(containerBuilder);
          return _serviceProviderFactory!
              .createServiceProvider(containerBuilder);
        };
      }
    }
  }

  @override
  Host build() => _hostApplicationBuilder.build();

  @override
  HostBuilder configureHostConfiguration(
      ConfigureHostConfigurationDelegate configureDelegate) {
    _configureHostConfigActions.add(configureDelegate);
    return this;
  }

  @override
  HostBuilder configureAppConfiguration(
      ConfigureAppConfigurationDelegate configureDelegate) {
    _configureAppConfigActions.add(configureDelegate);
    return this;
  }

  @override
  HostBuilder configureServices(ConfigureServicesDelegate configureDelegate) {
    _configureServicesActions.add(configureDelegate);
    return this;
  }

  @override
  HostBuilder useServiceProviderFactory<TContainerBuilder>({
    ServiceProviderFactory<TContainerBuilder>? implementation,
    FactoryResolver<TContainerBuilder>? factory,
  }) {
    _serviceProviderFactory = ServiceFactoryAdapter<TContainerBuilder>.builder(
      () => _hostApplicationBuilder._hostBuilderContext,
      factory!,
    );
    return this;
  }

  @override
  HostBuilder configureContainer<TContainerBuilder>(
    ConfigureContainerAdapterDelegate<TContainerBuilder> configureDelegate,
  ) {
    _configureContainerActions.add(
      ConfigureContainerAdapter<TContainerBuilder>(configureDelegate),
    );
    return this;
  }

  @override
  Map<Object, Object> get properties =>
      _hostApplicationBuilder._hostBuilderContext.properties;
}

class _LoggingBuilder implements LoggingBuilder {
  final ServiceCollection _serviceCollection;

  _LoggingBuilder(this._serviceCollection);

  @override
  ServiceCollection get services => _serviceCollection;
}
