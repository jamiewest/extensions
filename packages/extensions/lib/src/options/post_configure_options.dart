typedef PostConfigureActionT1<TOptions, TDep> = void Function(
    TOptions options, TDep dep);

typedef PostConfigureActionT2<TOptions, TDep1, TDep2> = void Function(
    TOptions options, TDep1 dep1, TDep2 dep2);

typedef PostConfigureActionT3<TOptions, TDep1, TDep2, TDep3> = void Function(
    TOptions options, TDep1 dep, TDep2 dep2, TDep3 dep3);

typedef PostConfigureActionT4<TOptions, TDep1, TDep2, TDep3, TDep4> = void
    Function(TOptions options, TDep1 dep, TDep2 dep2, TDep3 dep3, TDep4 dep4);

typedef PostConfigureActionT5<TOptions, TDep1, TDep2, TDep3, TDep4, TDep5>
    = void Function(TOptions options, TDep1 dep, TDep2 dep2, TDep3 dep3,
        TDep4 dep4, TDep5 dep5);

/// Represents something that configures the [TOptions] type.
abstract class IPostConfigureOptions<TOptions> {
  /// Invoked to configure a [TOptions] instance.
  void postConfigure(TOptions options, {String? name});
}

class PostConfigureOptions<TOptions>
    implements IPostConfigureOptions<TOptions> {
  /// Creates a new instance of [PostConfigureOptions<TOptions>].
  PostConfigureOptions(
    this.name,
    this.action,
  );

  /// The options name.
  final String? name;

  /// The initialization action.
  final dynamic action;

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
    String name,
    this.dependency1,
    dynamic action,
  ) : super(name, action);

  final TDep dependency1;

  @override
  void postConfigure(TOptions options, {String? name}) {
    if (this.name == null || name == this.name) {
      action.call(options, dependency1);
    }
  }
}

class PostConfigureOptions2<TOptions, TDep1, TDep2>
    extends PostConfigureOptions1<TOptions, TDep1> {
  PostConfigureOptions2(
    String name,
    TDep1 dependency1,
    this.dependency2,
    dynamic action,
  ) : super(name, dependency1, action);

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
    extends PostConfigureOptions2<TOptions, TDep1, TDep2> {
  PostConfigureOptions3(
    String name,
    TDep1 dependency1,
    TDep2 dependency2,
    this.dependency3,
    dynamic action,
  ) : super(name, dependency1, dependency2, action);

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
    extends PostConfigureOptions3<TOptions, TDep1, TDep2, TDep3> {
  PostConfigureOptions4(
    String name,
    TDep1 dependency1,
    TDep2 dependency2,
    TDep3 dependency3,
    this.dependency4,
    dynamic action,
  ) : super(
          name,
          dependency1,
          dependency2,
          dependency3,
          action,
        );

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
    extends PostConfigureOptions4<TOptions, TDep1, TDep2, TDep3, TDep4> {
  PostConfigureOptions5(
    String name,
    TDep1 dependency1,
    TDep2 dependency2,
    TDep3 dependency3,
    TDep4 dependency4,
    this.dependency5,
    dynamic action,
  ) : super(
          name,
          dependency1,
          dependency2,
          dependency3,
          dependency4,
          action,
        );

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
