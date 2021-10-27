import 'configure_options.dart';
import 'options.dart';

typedef ConfigureNamedOptionsActionT0<TOptions> = void Function(
  TOptions options,
);
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
abstract class ConfigureNamedOptions<TOptions>
    implements ConfigureOptions<TOptions> {
  /// Invoked to configure a [TOptions] instance.
  void configureNamed(String name, TOptions options);
}

class ConfigureNamedOptions0<TOptions>
    implements ConfigureNamedOptions<TOptions> {
  ConfigureNamedOptions0(
    this.name,
    this.action,
  );

  /// The options name.
  final String? name;

  /// The configuration action.
  final ConfigureNamedOptionsActionT0<TOptions> action;

  /// Invokes the registered initialization [action] if the [name] matches.
  @override
  void configureNamed(String name, TOptions options) {
    if (this.name == null || name == this.name) {
      action.call(options);
    }
  }

  @override
  void configure(TOptions options) => configureNamed(
        name ?? Options.defaultName,
        options,
      );
}

class ConfigureNamedOptions1<TOptions, TDep>
    implements ConfigureNamedOptions<TOptions> {
  ConfigureNamedOptions1(
    this.name,
    this.action,
    this.dependency,
  );

  /// The options name.
  final String? name;

  /// The configuration action.
  final ConfigureNamedOptionsActionT1<TOptions, TDep> action;

  /// The dependency.
  final TDep dependency;

  @override
  void configure(TOptions options, {String? name}) => configureNamed(
        name ?? Options.defaultName,
        options,
      );

  @override
  void configureNamed(String name, TOptions options) {
    if (this.name == null || name == this.name) {
      action.call(options, dependency);
    }
  }
}

class ConfigureNamedOptions2<TOptions, TDep1, TDep2>
    implements ConfigureNamedOptions<TOptions> {
  ConfigureNamedOptions2(
    this.name,
    this.action,
    this.dependency1,
    this.dependency2,
  );

  /// The options name.
  final String? name;

  /// The configuration action.
  final ConfigureNamedOptionsActionT2<TOptions, TDep1, TDep2> action;

  /// The dependency.
  final TDep1 dependency1;

  final TDep2 dependency2;

  @override
  void configure(TOptions options, {String? name}) => configureNamed(
        name ?? Options.defaultName,
        options,
      );

  @override
  void configureNamed(String name, TOptions options) {
    if (this.name == null || name == this.name) {
      action.call(options, dependency1, dependency2);
    }
  }
}

class ConfigureNamedOptions3<TOptions, TDep1, TDep2, TDep3>
    implements ConfigureNamedOptions<TOptions> {
  ConfigureNamedOptions3(
    this.name,
    this.action,
    this.dependency1,
    this.dependency2,
    this.dependency3,
  );

  /// The options name.
  final String? name;

  /// The configuration action.
  final ConfigureNamedOptionsActionT3<TOptions, TDep1, TDep2, TDep3> action;

  /// The first dependency.
  final TDep1 dependency1;

  /// The second dependency.
  final TDep2 dependency2;

  /// The third dependency.
  final TDep3 dependency3;

  @override
  void configure(TOptions options, {String? name}) => configureNamed(
        name ?? Options.defaultName,
        options,
      );

  @override
  void configureNamed(String name, TOptions options) {
    if (this.name == null || name == this.name) {
      action.call(
        options,
        dependency1,
        dependency2,
        dependency3,
      );
    }
  }
}

class ConfigureNamedOptions4<TOptions, TDep1, TDep2, TDep3, TDep4>
    implements ConfigureNamedOptions<TOptions> {
  ConfigureNamedOptions4(
    this.name,
    this.action,
    this.dependency1,
    this.dependency2,
    this.dependency3,
    this.dependency4,
  );

  /// The options name.
  final String? name;

  /// The configuration action.
  final ConfigureNamedOptionsActionT4<TOptions, TDep1, TDep2, TDep3, TDep4>
      action;

  /// The first dependency.
  final TDep1 dependency1;

  /// The second dependency.
  final TDep2 dependency2;

  /// The third dependency.
  final TDep3 dependency3;

  /// The fourth dependency.
  final TDep4 dependency4;

  @override
  void configure(TOptions options, {String? name}) => configureNamed(
        name ?? Options.defaultName,
        options,
      );

  @override
  void configureNamed(String name, TOptions options) {
    if (this.name == null || name == this.name) {
      action.call(
        options,
        dependency1,
        dependency2,
        dependency3,
        dependency4,
      );
    }
  }
}

class ConfigureNamedOptions5<TOptions, TDep1, TDep2, TDep3, TDep4, TDep5>
    implements ConfigureNamedOptions<TOptions> {
  ConfigureNamedOptions5(
    this.name,
    this.action,
    this.dependency1,
    this.dependency2,
    this.dependency3,
    this.dependency4,
    this.dependency5,
  );

  /// The options name.
  final String? name;

  /// The configuration action.
  final ConfigureNamedOptionsActionT5<TOptions, TDep1, TDep2, TDep3, TDep4,
      TDep5> action;

  /// The first dependency.
  final TDep1 dependency1;

  /// The second dependency.
  final TDep2 dependency2;

  /// The third dependency.
  final TDep3 dependency3;

  /// The fourth dependency.
  final TDep4 dependency4;

  /// The fifth dependency.
  final TDep5 dependency5;

  @override
  void configure(TOptions options, {String? name}) => configureNamed(
        name ?? Options.defaultName,
        options,
      );

  @override
  void configureNamed(String name, TOptions options) {
    if (this.name == null || name == this.name) {
      action.call(
        options,
        dependency1,
        dependency2,
        dependency3,
        dependency4,
        dependency5,
      );
    }
  }
}
