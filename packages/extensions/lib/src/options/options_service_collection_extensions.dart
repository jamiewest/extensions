import '../../options.dart';
import '../dependency_injection/service_collection.dart';
import '../dependency_injection/service_collection_descriptor_extensions.dart';
import '../dependency_injection/service_collection_service_extensions.dart';
import '../dependency_injection/service_descriptor.dart';
import '../dependency_injection/service_provider_service_extensions.dart';
import 'options_cache.dart';
import 'options_manager.dart';
import 'unnamed_options_manager.dart';
import 'validate_options.dart';

typedef ConfigureOptionsAction<TOptions> = void Function(TOptions options);
typedef OptionsImplementationFactory<T> = T Function();

/// Extension methods for adding options services to the DI container.
extension OptionsServiceCollectionExtensions on ServiceCollection {
  /// Adds services required for using options.
  ServiceCollection addOptions<TOptions>(
    OptionsImplementationFactory<TOptions> instance,
  ) {
    tryAdd(
      ServiceDescriptor.singleton<Options<TOptions>>(
        implementationFactory: (sp) => UnnamedOptionsManager<TOptions>(
          sp.getRequiredService<OptionsFactory<TOptions>>(),
        ),
      ),
    );

    tryAdd(
      ServiceDescriptor.scoped<OptionsSnapshot<TOptions>>(
        implementationFactory: (sp) => OptionsManager<TOptions>(
          instance,
          sp.getRequiredService<OptionsFactory<TOptions>>(),
        ),
      ),
    );

    tryAdd(
      ServiceDescriptor.singleton<OptionsMonitor<TOptions>>(
        implementationFactory: (sp) => OptionsMonitor<TOptions>(
          sp.getRequiredService<OptionsFactory<TOptions>>(),
          sp.getServices<OptionsChangeTokenSource<TOptions>>(),
          sp.getRequiredService<OptionsMonitorCache<TOptions>>(),
        ),
      ),
    );

    tryAdd(
      ServiceDescriptor.transient<OptionsFactory<TOptions>>(
        implementationFactory: (sp) => OptionsFactory<TOptions>(
          instance,
          setups: sp.getServices<ConfigureOptions<TOptions>>(),
          postConfigureOptions:
              sp.getServices<PostConfigureOptions<TOptions>>(),
          validations: sp.getServices<ValidateOptions<TOptions>>(),
        ),
      ),
    );

    tryAdd(
      ServiceDescriptor.singleton<OptionsMonitorCache<TOptions>>(
        implementationFactory: (sp) => OptionsCache<TOptions>(instance),
      ),
    );

    return this;
  }

  /// Registers an action used to configure a particular type of options.
  ServiceCollection configure<TOptions>(
      OptionsImplementationFactory<TOptions> instance,
      ConfigureOptionsAction<TOptions> configureOptions,
      {String? name}) {
    addOptions<TOptions>(instance);
    addSingleton<ConfigureOptions<TOptions>>(
      implementationInstance: ConfigureNamedOptions0<TOptions>(
        name,
        configureOptions,
      ),
    );
    return this;
  }

  /// Registers an action used to configure a particular type of options.
  ServiceCollection postConfigure<TOptions>(
    String name,
    OptionsImplementationFactory<TOptions> instance,
    PostConfigureActionT0<TOptions> configureOptions,
  ) {
    addOptions<TOptions>(instance);
    addSingleton<PostConfigureOptions<TOptions>>(
      implementationInstance: PostConfigureOptions0<TOptions>(
        name,
        configureOptions,
      ),
    );
    return this;
  }
}
