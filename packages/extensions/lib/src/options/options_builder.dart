import '../dependency_injection/service_collection.dart';
import '../dependency_injection/service_collection_service_extensions.dart';
import '../dependency_injection/service_provider_service_extensions.dart';
import 'configure_named_options.dart';
import 'configure_options.dart';
import 'options.dart';
import 'post_configure_options.dart';
import 'validate_options.dart';

// typedef ConfigureOptions<TOptions> = void Function(TOptions options);
// typedef ConfigureOptions1<TOptions, TDep> = void Function(
//     TOptions options, TDep dep);

/// Used to configure [TOptions] instances.
class OptionsBuilder<TOptions> {
  // final String _defaultValidationFailureMessage =
  //     'A validation error has occurred.';

  final String _name;

  /// Creates a new [OptionsBuilder] instance.
  OptionsBuilder(this.services, String? name)
      : _name = name ?? Options.defaultName;

  /// The default name of the [TOptions] instance.
  String get name => _name;

  /// The [ServiceCollection] for the options being configured.
  final ServiceCollection services;

  // ignore: avoid_returning_this
  OptionsBuilder<TOptions> configure(
    ConfigureNamedOptionsActionT0<TOptions> configureOptions,
  ) {
    services.addSingleton<ConfigureOptions<TOptions>>(
      (_) => ConfigureNamedOptions0<TOptions>(
        name,
        configureOptions,
      ),
    );
    return this;
  }

  // ignore: avoid_returning_this
  OptionsBuilder<TOptions> configure1<TDep>(
    ConfigureNamedOptionsActionT1<TOptions, TDep> configureOptions,
  ) {
    services.addTransient<ConfigureOptions<TOptions>>(
      (sp) => ConfigureNamedOptions1<TOptions, TDep>(
        name,
        configureOptions,
        sp.getRequiredService<TDep>(),
      ),
    );
    return this;
  }

  // ignore: avoid_returning_this
  OptionsBuilder<TOptions> configure2<TDep1, TDep2>(
    ConfigureNamedOptionsActionT2<TOptions, TDep1, TDep2> configureOptions,
  ) {
    services.addTransient<ConfigureOptions<TOptions>>(
      (sp) => ConfigureNamedOptions2<TOptions, TDep1, TDep2>(
        name,
        configureOptions,
        sp.getRequiredService<TDep1>(),
        sp.getRequiredService<TDep2>(),
      ),
    );
    return this;
  }

  // ignore: avoid_returning_this
  OptionsBuilder<TOptions> configure3<TDep1, TDep2, TDep3>(
    ConfigureNamedOptionsActionT3<TOptions, TDep1, TDep2, TDep3>
        configureOptions,
  ) {
    services.addTransient<ConfigureOptions<TOptions>>(
      (sp) => ConfigureNamedOptions3<TOptions, TDep1, TDep2, TDep3>(
        name,
        configureOptions,
        sp.getRequiredService<TDep1>(),
        sp.getRequiredService<TDep2>(),
        sp.getRequiredService<TDep3>(),
      ),
    );
    return this;
  }

  // ignore: avoid_returning_this
  OptionsBuilder<TOptions> configure4<TDep1, TDep2, TDep3, TDep4>(
    ConfigureNamedOptionsActionT4<TOptions, TDep1, TDep2, TDep3, TDep4>
        configureOptions,
  ) {
    services.addTransient<ConfigureOptions<TOptions>>(
      (sp) => ConfigureNamedOptions4<TOptions, TDep1, TDep2, TDep3, TDep4>(
        name,
        configureOptions,
        sp.getRequiredService<TDep1>(),
        sp.getRequiredService<TDep2>(),
        sp.getRequiredService<TDep3>(),
        sp.getRequiredService<TDep4>(),
      ),
    );
    return this;
  }

  // ignore: avoid_returning_this
  OptionsBuilder<TOptions> configure5<TDep1, TDep2, TDep3, TDep4, TDep5>(
    ConfigureNamedOptionsActionT5<TOptions, TDep1, TDep2, TDep3, TDep4, TDep5>
        configureOptions,
  ) {
    services.addTransient<ConfigureOptions<TOptions>>(
      (sp) =>
          ConfigureNamedOptions5<TOptions, TDep1, TDep2, TDep3, TDep4, TDep5>(
        name,
        configureOptions,
        sp.getRequiredService<TDep1>(),
        sp.getRequiredService<TDep2>(),
        sp.getRequiredService<TDep3>(),
        sp.getRequiredService<TDep4>(),
        sp.getRequiredService<TDep5>(),
      ),
    );
    return this;
  }

  // ignore: avoid_returning_this
  OptionsBuilder<TOptions> postConfigure(
    PostConfigureActionT0<TOptions> configureOptions,
  ) {
    services.addSingleton<PostConfigureOptions<TOptions>>(
      (_) => PostConfigureOptions0<TOptions>(
        name,
        configureOptions,
      ),
    );
    return this;
  }

  // ignore: avoid_returning_this
  OptionsBuilder<TOptions> postConfigure1<TDep>(
    PostConfigureActionT1<TOptions, TDep> configureOptions,
  ) {
    services.addTransient<PostConfigureOptions<TOptions>>(
      (sp) => PostConfigureOptions1<TOptions, TDep>(
        name,
        sp.getRequiredService<TDep>(),
        configureOptions,
      ),
    );
    return this;
  }

  // ignore: avoid_returning_this
  OptionsBuilder<TOptions> postConfigure2<TDep1, TDep2>(
    PostConfigureActionT2<TOptions, TDep1, TDep2> configureOptions,
  ) {
    services.addTransient<PostConfigureOptions<TOptions>>(
      (sp) => PostConfigureOptions2<TOptions, TDep1, TDep2>(
        name,
        configureOptions,
        sp.getRequiredService<TDep1>(),
        sp.getRequiredService<TDep2>(),
      ),
    );
    return this;
  }

  // ignore: avoid_returning_this
  OptionsBuilder<TOptions> postConfigure3<TDep1, TDep2, TDep3>(
    PostConfigureActionT3<TOptions, TDep1, TDep2, TDep3> configureOptions,
  ) {
    services.addTransient<PostConfigureOptions<TOptions>>(
      (sp) => PostConfigureOptions3<TOptions, TDep1, TDep2, TDep3>(
        name,
        configureOptions,
        sp.getRequiredService<TDep1>(),
        sp.getRequiredService<TDep2>(),
        sp.getRequiredService<TDep3>(),
      ),
    );
    return this;
  }

  // ignore: avoid_returning_this
  OptionsBuilder<TOptions> postConfigure4<TDep1, TDep2, TDep3, TDep4>(
    PostConfigureActionT4<TOptions, TDep1, TDep2, TDep3, TDep4>
        configureOptions,
  ) {
    services.addTransient<PostConfigureOptions<TOptions>>(
      (sp) => PostConfigureOptions4<TOptions, TDep1, TDep2, TDep3, TDep4>(
        name,
        configureOptions,
        sp.getRequiredService<TDep1>(),
        sp.getRequiredService<TDep2>(),
        sp.getRequiredService<TDep3>(),
        sp.getRequiredService<TDep4>(),
      ),
    );
    return this;
  }

  // ignore: avoid_returning_this
  OptionsBuilder<TOptions> postConfigure5<TDep1, TDep2, TDep3, TDep4, TDep5>(
    PostConfigureActionT5<TOptions, TDep1, TDep2, TDep3, TDep4, TDep5>
        configureOptions,
  ) {
    services.addTransient<PostConfigureOptions<TOptions>>(
      (sp) =>
          PostConfigureOptions5<TOptions, TDep1, TDep2, TDep3, TDep4, TDep5>(
        name,
        configureOptions,
        sp.getRequiredService<TDep1>(),
        sp.getRequiredService<TDep2>(),
        sp.getRequiredService<TDep3>(),
        sp.getRequiredService<TDep4>(),
        sp.getRequiredService<TDep5>(),
      ),
    );
    return this;
  }

  // ignore: avoid_returning_this
  OptionsBuilder<TOptions> validate(
    ValidationCallback0<TOptions> validation,
    String failureMessage,
  ) {
    services.addSingleton<ValidateOptions<TOptions>>(
      (_) => ValidateOptions0<TOptions>(
        name,
        validation,
        failureMessage,
      ),
    );
    return this;
  }

  // ignore: avoid_returning_this
  OptionsBuilder<TOptions> validate1<TDep>(
    ValidationCallback1<TOptions, TDep> validation,
    String failureMessage,
  ) {
    services.addTransient<ValidateOptions<TOptions>>(
      (sp) => ValidateOptions1<TOptions, TDep>(
        name,
        validation,
        failureMessage,
        sp.getRequiredService<TDep>(),
      ),
    );
    return this;
  }

  // ignore: avoid_returning_this
  OptionsBuilder<TOptions> validate2<TDep1, TDep2>(
    ValidationCallback2<TOptions, TDep1, TDep2> validation,
    String failureMessage,
  ) {
    services.addTransient<ValidateOptions<TOptions>>(
      (sp) => ValidateOptions2<TOptions, TDep1, TDep2>(
        name,
        validation,
        failureMessage,
        sp.getRequiredService<TDep1>(),
        sp.getRequiredService<TDep2>(),
      ),
    );
    return this;
  }

  // ignore: avoid_returning_this
  OptionsBuilder<TOptions> validate3<TDep1, TDep2, TDep3>(
    ValidationCallback3<TOptions, TDep1, TDep2, TDep3> validation,
    String failureMessage,
  ) {
    services.addTransient<ValidateOptions<TOptions>>(
      (sp) => ValidateOptions3<TOptions, TDep1, TDep2, TDep3>(
        name,
        validation,
        failureMessage,
        sp.getRequiredService<TDep1>(),
        sp.getRequiredService<TDep2>(),
        sp.getRequiredService<TDep3>(),
      ),
    );
    return this;
  }

  // ignore: avoid_returning_this
  OptionsBuilder<TOptions> validate4<TDep1, TDep2, TDep3, TDep4>(
    ValidationCallback4<TOptions, TDep1, TDep2, TDep3, TDep4> validation,
    String failureMessage,
  ) {
    services.addTransient<ValidateOptions<TOptions>>(
      (sp) => ValidateOptions4<TOptions, TDep1, TDep2, TDep3, TDep4>(
        name,
        validation,
        failureMessage,
        sp.getRequiredService<TDep1>(),
        sp.getRequiredService<TDep2>(),
        sp.getRequiredService<TDep3>(),
        sp.getRequiredService<TDep4>(),
      ),
    );
    return this;
  }

  // ignore: avoid_returning_this
  OptionsBuilder<TOptions> validate5<TDep1, TDep2, TDep3, TDep4, TDep5>(
    ValidationCallback5<TOptions, TDep1, TDep2, TDep3, TDep4, TDep5> validation,
    String failureMessage,
  ) {
    services.addTransient<ValidateOptions<TOptions>>(
      (sp) => ValidateOptions5<TOptions, TDep1, TDep2, TDep3, TDep4, TDep5>(
        name,
        validation,
        failureMessage,
        sp.getRequiredService<TDep1>(),
        sp.getRequiredService<TDep2>(),
        sp.getRequiredService<TDep3>(),
        sp.getRequiredService<TDep4>(),
        sp.getRequiredService<TDep5>(),
      ),
    );
    return this;
  }
}
