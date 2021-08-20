import '../../dependency_injection.dart';
import '../../options.dart';
import 'options_cache.dart';
import 'options_manager.dart';
import 'unnamed_options_manager.dart';
import 'validate_options.dart';

typedef ConfigureOptionsAction<TOptions> = void Function(TOptions options);
typedef ImplementationFactory<T> = T Function();

/// Extension methods for adding options services to the DI container.
extension OptionsServiceCollectionExtensions on ServiceCollection {
  /// Adds services required for using options.
  ServiceCollection addOptions<TOptions>(
    ImplementationFactory<TOptions> instance,
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
          setups: sp.getServices<IConfigureOptions<TOptions>>(),
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
      ImplementationFactory<TOptions> instance,
      ConfigureOptionsAction<TOptions> configureOptions,
      {String? name}) {
    addOptions<TOptions>(instance);
    addSingleton<IConfigureOptions<TOptions>>(
      implementationInstance: ConfigureNamedOptions<TOptions>(
        name,
        configureOptions,
      ),
    );
    return this;
  }
}
