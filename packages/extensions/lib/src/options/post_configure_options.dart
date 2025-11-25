typedef PostConfigureActionT0<TOptions> = void Function(TOptions options);
typedef PostConfigureActionT1<TOptions, TDep> = void Function(
  TOptions options,
  TDep dep,
);

typedef PostConfigureActionT2<TOptions, TDep1, TDep2> = void Function(
  TOptions options,
  TDep1 dep1,
  TDep2 dep2,
);

typedef PostConfigureActionT3<TOptions, TDep1, TDep2, TDep3> = void Function(
  TOptions options,
  TDep1 dep,
  TDep2 dep2,
  TDep3 dep3,
);

typedef PostConfigureActionT4<TOptions, TDep1, TDep2, TDep3, TDep4> = void
    Function(
  TOptions options,
  TDep1 dep,
  TDep2 dep2,
  TDep3 dep3,
  TDep4 dep4,
);

typedef PostConfigureActionT5<TOptions, TDep1, TDep2, TDep3, TDep4, TDep5>
    = void Function(
  TOptions options,
  TDep1 dep,
  TDep2 dep2,
  TDep3 dep3,
  TDep4 dep4,
  TDep5 dep5,
);

/// Represents something that configures the [TOptions] type.
abstract class PostConfigureOptions<TOptions> {
  /// Invoked to configure a [TOptions] instance.
  void postConfigure(TOptions options, {String? name});
}

class PostConfigureOptions0<TOptions>
    implements PostConfigureOptions<TOptions> {
  /// Creates a new instance of [PostConfigureOptions<TOptions>].
  PostConfigureOptions0(
    this.name,
    this.action,
  );

  /// The options name.
  final String? name;

  /// The initialization action.
  final PostConfigureActionT0<TOptions> action;

  /// Invokes the registered initialization [action] if the [name] matches.
  @override
  void postConfigure(TOptions options, {String? name}) {
    if (this.name == null || name == this.name) {
      action.call(options);
    }
  }
}

class PostConfigureOptions1<TOptions, TDep>
    extends PostConfigureOptions<TOptions> {
  PostConfigureOptions1(
    this.name,
    this.dependency,
    this.action,
  );

  /// The options name.
  final String? name;

  /// The configuration action.
  final PostConfigureActionT1<TOptions, TDep> action;

  /// The dependency.
  final TDep dependency;

  @override
  void postConfigure(TOptions options, {String? name}) {
    if (this.name == null || name == this.name) {
      action.call(options, dependency);
    }
  }
}

class PostConfigureOptions2<TOptions, TDep1, TDep2>
    implements PostConfigureOptions<TOptions> {
  PostConfigureOptions2(
    this.name,
    this.action,
    this.dependency1,
    this.dependency2,
  );

  /// The options name.
  final String? name;

  /// The configuration action.
  final PostConfigureActionT2<TOptions, TDep1, TDep2> action;

  /// The first dependency.
  final TDep1 dependency1;

  /// The second dependency.
  final TDep2 dependency2;

  @override
  void postConfigure(TOptions options, {String? name}) {
    if (this.name == null || name == this.name) {
      action.call(
        options,
        dependency1,
        dependency2,
      );
    }
  }
}

class PostConfigureOptions3<TOptions, TDep1, TDep2, TDep3>
    implements PostConfigureOptions<TOptions> {
  PostConfigureOptions3(
    this.name,
    this.action,
    this.dependency1,
    this.dependency2,
    this.dependency3,
  );

  /// The options name.
  final String? name;

  /// The configuration action.
  final PostConfigureActionT3<TOptions, TDep1, TDep2, TDep3> action;

  /// The first dependency.
  final TDep1 dependency1;

  /// The second dependency.
  final TDep2 dependency2;

  /// The third dependency.
  final TDep3 dependency3;

  @override
  void postConfigure(TOptions options, {String? name}) {
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

class PostConfigureOptions4<TOptions, TDep1, TDep2, TDep3, TDep4>
    implements PostConfigureOptions<TOptions> {
  PostConfigureOptions4(
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
  final PostConfigureActionT4<TOptions, TDep1, TDep2, TDep3, TDep4> action;

  /// The first dependency.
  final TDep1 dependency1;

  /// The second dependency.
  final TDep2 dependency2;

  /// The third dependency.
  final TDep3 dependency3;

  /// The fourth dependency.
  final TDep4 dependency4;

  @override
  void postConfigure(TOptions options, {String? name}) {
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

class PostConfigureOptions5<TOptions, TDep1, TDep2, TDep3, TDep4, TDep5>
    implements PostConfigureOptions<TOptions> {
  PostConfigureOptions5(
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
  final PostConfigureActionT5<TOptions, TDep1, TDep2, TDep3, TDep4, TDep5>
      action;

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
  void postConfigure(TOptions options, {String? name}) {
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
