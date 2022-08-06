import '../dependency_injection/service_collection.dart';
import '../dependency_injection/service_collection_descriptor_extensions.dart';
import '../dependency_injection/service_collection_service_extensions.dart';
import '../dependency_injection/service_descriptor.dart';
import '../dependency_injection/service_provider_service_extensions.dart';
import 'configure_named_options.dart';
import 'configure_options.dart';
import 'options.dart';
import 'options_builder.dart';
import 'options_cache.dart';
import 'options_change_token_source.dart';
import 'options_factory.dart';
import 'options_manager.dart';
import 'options_monitor.dart';
import 'options_monitor_cache.dart';
import 'options_snapshot.dart';
import 'post_configure_options.dart';
import 'unnamed_options_manager.dart';
import 'validate_options.dart';

typedef ConfigureOptionsAction<TOptions> = void Function(TOptions options);
typedef OptionsImplementationFactory<T> = T Function();

/// Extension methods for adding options services to the DI container.
extension OptionsServiceCollectionExtensions on ServiceCollection {
  /// Adds services required for using options.
  OptionsBuilder<TOptions> addOptions<TOptions>(
    OptionsImplementationFactory<TOptions> instance, {
    String name = Options.defaultName,
  }) {
    tryAdd(
      ServiceDescriptor.singleton<Options<TOptions>,
          UnnamedOptionsManager<TOptions>>(
        (sp) => UnnamedOptionsManager<TOptions>(
          sp.getRequiredService<OptionsFactory<TOptions>>()
              as OptionsFactory<TOptions>,
        ),
      ),
    );

    tryAdd(
      ServiceDescriptor.scoped<OptionsSnapshot<TOptions>,
          OptionsManager<TOptions>>(
        (sp) => OptionsManager<TOptions>(
          instance,
          sp.getRequiredService<OptionsFactory<TOptions>>()
              as OptionsFactory<TOptions>,
        ),
      ),
    );

    tryAdd(
      ServiceDescriptor.singleton<OptionsMonitor<TOptions>,
          OptionsMonitor<TOptions>>(
        (sp) => OptionsMonitor<TOptions>(
          sp.getRequiredService<OptionsFactory<TOptions>>()
              as OptionsFactory<TOptions>,
          (sp.getServices<OptionsChangeTokenSource<TOptions>>() as List)
              .map((item) => item as OptionsChangeTokenSource<TOptions>)
              .toList(),
          sp.getRequiredService<OptionsMonitorCache<TOptions>>()
              as OptionsMonitorCache<TOptions>,
        ),
      ),
    );

    tryAdd(
      ServiceDescriptor.transient<OptionsFactory<TOptions>,
          OptionsFactory<TOptions>>(
        (sp) => OptionsFactory<TOptions>(
          instance,
          setups: (sp.getServices<ConfigureOptions<TOptions>>() as List)
              .map((item) => item as ConfigureOptions<TOptions>)
              .toList(),
          postConfigureOptions:
              (sp.getServices<PostConfigureOptions<TOptions>>() as List)
                  .map((item) => item as PostConfigureOptions<TOptions>)
                  .toList(),
          validations: (sp.getServices<ValidateOptions<TOptions>>() as List)
              .map((item) => item as ValidateOptions<TOptions>)
              .toList(),
        ),
      ),
    );

    tryAdd(
      ServiceDescriptor.singleton<OptionsMonitorCache<TOptions>,
          OptionsCache<TOptions>>(
        (sp) => OptionsCache<TOptions>(instance),
      ),
    );

    return OptionsBuilder<TOptions>(
      this,
      name,
    );
  }

  /// Registers an action used to configure a particular type of options.
  ServiceCollection configure<TOptions>(
      OptionsImplementationFactory<TOptions> instance,
      ConfigureOptionsAction<TOptions> configureOptions,
      {String? name}) {
    addOptions<TOptions>(instance);
    addSingleton<ConfigureOptions<TOptions>, ConfigureNamedOptions0<TOptions>>(
      (_) => ConfigureNamedOptions0<TOptions>(
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
    addSingleton<PostConfigureOptions<TOptions>,
        PostConfigureOptions0<TOptions>>(
      (_) => PostConfigureOptions0<TOptions>(
        name,
        configureOptions,
      ),
    );
    return this;
  }
}
