import 'configure_options.dart';
import 'options.dart';

typedef ConfigureNamedOptionsActionT1<TOptions, TDep> = void Function(
  TOptions options,
  TDep dep,
);
typedef ConfigureNamedOptionsActionT2<TOptions, TDep1, TDep2> = void Function(
  TOptions options,
  TDep1 dep1,
  TDep2 dep2,
);
typedef ConfigureNamedOptionsActionT3<TOptions, TDep1, TDep2, TDep3> = void
    Function(
  TOptions options,
  TDep1 dep1,
  TDep2 dep2,
  TDep3 dep3,
);
typedef ConfigureNamedOptionsActionT4<TOptions, TDep1, TDep2, TDep3, TDep4>
    = void Function(
  TOptions options,
  TDep1 dep1,
  TDep2 dep2,
  TDep3 dep3,
  TDep4 dep4,
);
typedef ConfigureNamedOptionsActionT5<TOptions, TDep1, TDep2, TDep3, TDep4,
        TDep5>
    = void Function(
  TOptions options,
  TDep1 dep1,
  TDep2 dep2,
  TDep3 dep3,
  TDep4 dep4,
  TDep5 dep5,
);

/// Represents something that configures the [TOptions] type.
abstract class IConfigureNamedOptions<TOptions>
    implements IConfigureOptions<TOptions> {
  /// Invoked to configure a [TOptions] instance.
  void configureNamed(String name, TOptions options);
}

class ConfigureNamedOptions<TOptions>
    implements IConfigureNamedOptions<TOptions> {
  /// Creates a new instance of [PostConfigureOptions<TOptions>].
  ConfigureNamedOptions(
    this.name,
    this.action,
  );

  /// The options name. n 7
  final String? name;

  /// The initialization action.
  final dynamic action;

  /// Invokes the registered initialization [action] if the [name] matches.
  @override
  void configureNamed(String name, TOptions options) {
    if (this.name == null || name == this.name) {
      action.call(options);
    }
  }

  @override
  void configure(TOptions options) => configureNamed(
        Options.defaultName,
        options,
      );
}

class ConfigureNamedOptions1<TOptions, TDep>
    extends ConfigureNamedOptions<TOptions> {
  ConfigureNamedOptions1(
    String name,
    this.dependency,
    dynamic action,
  ) : super(name, action);

  final TDep dependency;

  @override
  void configure(TOptions options, {String? name}) {
    if (this.name == null || name == this.name) {
      action.call(options, dependency);
    }
  }
}

class ConfigureNamedOptions2<TOptions, TDep1, TDep2>
    extends ConfigureNamedOptions1<TOptions, TDep1> {
  ConfigureNamedOptions2(
    String name,
    TDep1 dependency1,
    this.dependency2,
    dynamic action,
  ) : super(name, dependency1, action);

  final TDep2 dependency2;

  @override
  void configure(TOptions options, {String? name}) {
    if (this.name == null || name == this.name) {
      action.call(options, dependency, dependency2);
    }
  }
}
