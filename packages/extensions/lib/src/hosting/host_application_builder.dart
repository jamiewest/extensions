import 'package:path/path.dart' as p;

import '../../diagnostics.dart';
import '../configuration/configuration_manager.dart';
import '../configuration/memory_configuration_builder_extensions.dart';
import '../configuration/providers/environment_variables/environment_variables_extensions.dart';
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
import 'hosting_host_builder_extensions.dart' as hosting_ext;
import 'hosting_host_builder_extensions_io.dart' as hosting_ext_io;
import 'internal/configure_container_adapter.dart';
import 'internal/service_factory_adapter.dart';

typedef ConfigureContainerBuilder<TContainerBuilder> = void Function(
  TContainerBuilder containerBuilder,
);

typedef ConfigureContainer<TContainerBuilder> = void Function(
  TContainerBuilder containerBuilder,
);

typedef CreateServiceProvider = ServiceProvider Function();

/// Represents a hosted applications and services builder which helps manage
/// configuration, logging, lifetime, and more.
abstract class HostApplicationBuilder {
  /// Initializes a new instance of the [HostApplicationBuilder] class with
  /// optional [settings].
  factory HostApplicationBuilder({HostApplicationBuilderSettings? settings}) =>
      DefaultHostApplicationBuilder(settings: settings);

  /// Gets a central location for sharing state between components during the
  /// host building process.
  Map<Object, Object> get properties;

  /// Gets the set of key/value configuration properties.
  ConfigurationManager get configuration;

  /// Gets the information about the hosting environment an application is
  /// running in.
  HostEnvironment get environment;

  /// Gets a collection of logging providers for the application to compose.
  /// This is useful for adding new logging providers.
  LoggingBuilder get logging;

  /// Gets a builder that allows enabling metrics and directing their output.
  MetricsBuilder get metrics;

  /// Gets a collection of services for the application to compose. This is
  /// useful for adding user provided or framework provided services.
  ServiceCollection get services;

  /// Registers a [ServiceProviderFactory<TContainerBuilder>] instance to be
  /// used to create the [ServiceProvider].
  void configureContainer<TContainerBuilder>(
    ServiceProviderFactory<TContainerBuilder> factory,
    ConfigureContainerBuilder<TContainerBuilder>? configure,
  );

  /// Builds the host. This method can only be called once.
  Host build();
}

/// Represents a hosted applications and services builder that helps manage
/// configuration, logging, lifetime, and more.
class DefaultHostApplicationBuilder implements HostApplicationBuilder {
  late final HostBuilderContext _hostBuilderContext;
  final ServiceCollection _serviceCollection = ServiceCollection();
  late final HostEnvironment _environment;
  late final LoggingBuilder _logging;
  late final MetricsBuilder _metrics;

  late final CreateServiceProvider _createServiceProvider;
  ConfigureContainer<Object> _configureContainer = (_) => {};
  HostBuilderAdapter? _hostBuilderAdapter;

  ServiceProvider? _appServices;
  bool _hostBuilt;

  late final ConfigurationManager _configuration;

  DefaultHostApplicationBuilder({HostApplicationBuilderSettings? settings})
      : _hostBuilt = false {
    settings ??= HostApplicationBuilderSettings();
    _configuration = settings.configuration ?? ConfigurationManager();

    if (!settings.disableDefaults) {
      if (settings.configurationRootPath == null &&
          configuration[HostDefaults.contentRootKey] == null) {
        hosting_ext.setDefaultContentRoot(configuration);
      }

      configuration.addEnvironmentVariables(prefix: 'DOTNET_');
    }

    List<MapEntry<String, String>>? optionList;
    if (settings.applicationName != null) {
      optionList ??= <MapEntry<String, String>>[];
      optionList.add(
        MapEntry(HostDefaults.applicationKey, settings.applicationName!),
      );
    }
    if (settings.environmentName != null) {
      optionList ??= <MapEntry<String, String>>[];
      optionList.add(
        MapEntry(HostDefaults.environmentKey, settings.environmentName!),
      );
    }
    if (settings.configurationRootPath != null) {
      optionList ??= <MapEntry<String, String>>[];
      optionList.add(
        MapEntry(HostDefaults.contentRootKey, settings.configurationRootPath!),
      );
    }
    if (optionList != null) {
      configuration.addInMemoryCollection(optionList);
    }

    _environment = createHostingEnvironment(configuration);

    _hostBuilderContext = HostBuilderContext(<Object, Object>{})
      ..hostingEnvironment = _environment
      ..configuration = configuration;

    populateServiceCollection(
      services,
      _hostBuilderContext,
      _environment,
      configuration,
      () => _appServices!,
    );

    _logging = _LoggingBuilder(services);
    _metrics = _MetricsBuilder(services);

    // Apply default app configuration (appsettings.json, environment
    // variables, command line)
    if (!settings.disableDefaults) {
      hosting_ext_io.applyDefaultAppConfiguration(
        _hostBuilderContext,
        configuration,
        settings.args,
      );
    }

    ServiceProviderOptions? serviceProviderOptions;

    if (!settings.disableDefaults) {
      hosting_ext_io.addDefaultServices(
        _hostBuilderContext,
        services,
      );
      serviceProviderOptions =
          hosting_ext_io.createDefaultServiceProviderOptions(
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

  /// Gets a central location for sharing state between components
  /// during the host building process.
  @override
  Map<Object, Object> get properties => _hostBuilderContext.properties;

  /// Gets the information about the hosting environment an application
  /// is running in.
  @override
  HostEnvironment get environment => _environment;

  /// Gets the set of key/value configuration properties.
  ///
  /// This can be mutated by adding more configuration sources, which
  /// will update its current view.
  @override
  ConfigurationManager get configuration => _configuration;

  /// Gets a collection of services for the application to compose. This is
  /// useful for adding user provided or framework provided services.
  @override
  ServiceCollection get services => _serviceCollection;

  /// Gets a collection of logging providers for the application to
  /// compose. This is useful for adding new logging providers.
  @override
  LoggingBuilder get logging => _logging;

  /// Gets a builder that allows enabling metrics and directing their output.
  @override
  MetricsBuilder get metrics => _metrics;

  /// Registers a [ServiceProviderFactory] instance to be used to create
  /// the [ServiceProvider].
  @override
  void configureContainer<TContainerBuilder>(
    ServiceProviderFactory<TContainerBuilder> factory,
    ConfigureContainer<TContainerBuilder>? configure,
  ) {
    _createServiceProvider = () {
      var containerBuilder = factory.createBuilder(_serviceCollection);
      configure?.call(containerBuilder);
      return factory.createServiceProvider(containerBuilder);
    };

    // Store _configureContainer separately so it an be replaced individually
    // by the HostBuilderAdapter.
    _configureContainer = (containerBuilder) {
      configure?.call(containerBuilder as TContainerBuilder);
    };
  }

  @override
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
  final List<DefaultConfigureContainerAdapter<dynamic>>
      _configureContainerActions =
      <DefaultConfigureContainerAdapter<dynamic>>[];
  final List<ConfigureServicesDelegate> _configureServicesActions =
      <ConfigureServicesDelegate>[];

  ServiceFactoryAdapter? _serviceProviderFactory;

  HostBuilderAdapter(HostApplicationBuilder hostApplicationBuilder)
      : _hostApplicationBuilder = hostApplicationBuilder;

  void applyChanges() {
    var config = _hostApplicationBuilder.configuration;

    if (_configureHostConfigActions.isNotEmpty) {
      var previousApplicationName = config[HostDefaults.applicationKey];
      var previousEnvironment = config[HostDefaults.environmentKey];
      var previousContentRootConfig = config[HostDefaults.contentRootKey];
      var previousContentRootPath =
          (_hostApplicationBuilder as DefaultHostApplicationBuilder)
              ._hostBuilderContext
              .hostingEnvironment
              ?.contentRootPath;

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
      configureAppAction(
          (_hostApplicationBuilder as DefaultHostApplicationBuilder)
              ._hostBuilderContext,
          config);
    }
    for (var configureServicesAction in _configureServicesActions) {
      configureServicesAction(
        (_hostApplicationBuilder as DefaultHostApplicationBuilder)
            ._hostBuilderContext,
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
    _serviceProviderFactory =
        DefaultServiceFactoryAdapter<TContainerBuilder>.builder(
      () => (_hostApplicationBuilder as DefaultHostApplicationBuilder)
          ._hostBuilderContext,
      factory!,
    );
    return this;
  }

  @override
  HostBuilder configureContainer<TContainerBuilder>(
    ConfigureContainerAdapterDelegate<TContainerBuilder> configureDelegate,
  ) {
    _configureContainerActions.add(
      DefaultConfigureContainerAdapter<TContainerBuilder>(configureDelegate),
    );
    return this;
  }

  @override
  Map<Object, Object> get properties =>
      (_hostApplicationBuilder as DefaultHostApplicationBuilder)
          ._hostBuilderContext
          .properties;
}

class _LoggingBuilder implements LoggingBuilder {
  final ServiceCollection _serviceCollection;

  _LoggingBuilder(this._serviceCollection);

  @override
  ServiceCollection get services => _serviceCollection;
}

class _MetricsBuilder implements MetricsBuilder {
  final ServiceCollection _serviceCollection;

  _MetricsBuilder(this._serviceCollection);

  @override
  ServiceCollection get services => _serviceCollection;
}
