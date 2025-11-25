import 'validate_options_result.dart';

typedef ValidationCallback0<TOptions> = bool Function(TOptions options);
typedef ValidationCallback1<TOptions, TDep> = bool Function(
  TOptions options,
  TDep dependency,
);
typedef ValidationCallback2<TOptions, TDep1, TDep2> = bool Function(
  TOptions options,
  TDep1 dependency1,
  TDep2 dependency2,
);
typedef ValidationCallback3<TOptions, TDep1, TDep2, TDep3> = bool Function(
  TOptions options,
  TDep1 dependency1,
  TDep2 dependency2,
  TDep3 dependency3,
);
typedef ValidationCallback4<TOptions, TDep1, TDep2, TDep3, TDep4> = bool
    Function(
  TOptions options,
  TDep1 dependency1,
  TDep2 dependency2,
  TDep3 dependency3,
  TDep4 dependency4,
);
typedef ValidationCallback5<TOptions, TDep1, TDep2, TDep3, TDep4, TDep5> = bool
    Function(
  TOptions options,
  TDep1 dependency1,
  TDep2 dependency2,
  TDep3 dependency3,
  TDep4 dependency4,
  TDep5 dependency5,
);

/// Interface used to validate options.
abstract class ValidateOptions<TOptions> {
  /// Validates a specific named options instance (or all when name is null).
  ValidateOptionsResult validate(
    String name,
    TOptions options,
  );
}

/// Implementation of [ValidateOptions<TOptions>]
class ValidateOptions0<TOptions> implements ValidateOptions<TOptions> {
  const ValidateOptions0(
    this.name,
    this.validation,
    this.failureMessage,
  );

  /// The options name.
  final String name;

  /// The validation function.
  final ValidationCallback0<TOptions>? validation;

  /// The error to return when validation fails.
  final String failureMessage;

  /// Validates a specific named options instance (or all when [name] is null).
  @override
  ValidateOptionsResult validate(String name, TOptions options) {
    // null name is used to configure all named options
    if (name == name || name == name) {
      if (validation != null) {
        if (validation!.call(options)) {
          return ValidateOptionsResult.success;
        }
      }

      return ValidateOptionsResult.fail([failureMessage]);
    }

    // ignored if not validating this instance
    return ValidateOptionsResult.skip;
  }
}

class ValidateOptions1<TOptions, TDep> implements ValidateOptions<TOptions> {
  const ValidateOptions1(
    this.name,
    this.validation,
    this.failureMessage,
    this.dependency,
  );

  /// The options name.
  final String name;

  /// The validation function.
  final ValidationCallback1<TOptions, TDep>? validation;

  /// The error to return when validation fails.
  final String failureMessage;

  /// The dependency.
  final TDep dependency;

  /// Validates a specific named options instance (or all when [name] is null).
  @override
  ValidateOptionsResult validate(String name, TOptions options) {
    // null name is used to configure all named options
    if (name == name || name == name) {
      if (validation != null) {
        if (validation!.call(options, dependency)) {
          return ValidateOptionsResult.success;
        }
      }

      return ValidateOptionsResult.fail([failureMessage]);
    }

    // ignored if not validating this instance
    return ValidateOptionsResult.skip;
  }
}

class ValidateOptions2<TOptions, TDep1, TDep2>
    implements ValidateOptions<TOptions> {
  const ValidateOptions2(
    this.name,
    this.validation,
    this.failureMessage,
    this.dependency1,
    this.dependency2,
  );

  /// The options name.
  final String name;

  /// The validation function.
  final ValidationCallback2<TOptions, TDep1, TDep2>? validation;

  /// The error to return when validation fails.
  final String failureMessage;

  /// The first dependency.
  final TDep1 dependency1;

  /// The second dependency.
  final TDep2 dependency2;

  @override
  ValidateOptionsResult validate(String name, TOptions options) {
    // null name is used to configure all named options
    if (name == name || name == name) {
      if (validation != null) {
        if (validation!.call(
          options,
          dependency1,
          dependency2,
        )) {
          return ValidateOptionsResult.success;
        }
      }

      return ValidateOptionsResult.fail([failureMessage]);
    }

    // ignored if not validating this instance
    return ValidateOptionsResult.skip;
  }
}

class ValidateOptions3<TOptions, TDep1, TDep2, TDep3>
    implements ValidateOptions<TOptions> {
  const ValidateOptions3(
    this.name,
    this.validation,
    this.failureMessage,
    this.dependency1,
    this.dependency2,
    this.dependency3,
  );

  /// The options name.
  final String name;

  /// The validation function.
  final ValidationCallback3<TOptions, TDep1, TDep2, TDep3>? validation;

  /// The error to return when validation fails.
  final String failureMessage;

  /// The first dependency.
  final TDep1 dependency1;

  /// The second dependency.
  final TDep2 dependency2;

  /// The third dependency.
  final TDep3 dependency3;

  @override
  ValidateOptionsResult validate(String name, TOptions options) {
    // null name is used to configure all named options
    if (name == name || name == name) {
      if (validation != null) {
        if (validation!.call(
          options,
          dependency1,
          dependency2,
          dependency3,
        )) {
          return ValidateOptionsResult.success;
        }
      }

      return ValidateOptionsResult.fail([failureMessage]);
    }

    // ignored if not validating this instance
    return ValidateOptionsResult.skip;
  }
}

class ValidateOptions4<TOptions, TDep1, TDep2, TDep3, TDep4>
    implements ValidateOptions<TOptions> {
  const ValidateOptions4(
    this.name,
    this.validation,
    this.failureMessage,
    this.dependency1,
    this.dependency2,
    this.dependency3,
    this.dependency4,
  );

  /// The options name.
  final String name;

  /// The validation function.
  final ValidationCallback4<TOptions, TDep1, TDep2, TDep3, TDep4>? validation;

  /// The error to return when validation fails.
  final String failureMessage;

  /// The first dependency.
  final TDep1 dependency1;

  /// The second dependency.
  final TDep2 dependency2;

  /// The third dependency.
  final TDep3 dependency3;

  /// The fourth dependency.
  final TDep4 dependency4;

  @override
  ValidateOptionsResult validate(String name, TOptions options) {
    // null name is used to configure all named options
    if (name == name || name == name) {
      if (validation != null) {
        if (validation!.call(
          options,
          dependency1,
          dependency2,
          dependency3,
          dependency4,
        )) {
          return ValidateOptionsResult.success;
        }
      }

      return ValidateOptionsResult.fail([failureMessage]);
    }

    // ignored if not validating this instance
    return ValidateOptionsResult.skip;
  }
}

class ValidateOptions5<TOptions, TDep1, TDep2, TDep3, TDep4, TDep5>
    implements ValidateOptions<TOptions> {
  const ValidateOptions5(
    this.name,
    this.validation,
    this.failureMessage,
    this.dependency1,
    this.dependency2,
    this.dependency3,
    this.dependency4,
    this.dependency5,
  );

  /// The options name.
  final String name;

  /// The validation function.
  final ValidationCallback5<TOptions, TDep1, TDep2, TDep3, TDep4, TDep5>?
      validation;

  /// The error to return when validation fails.
  final String failureMessage;

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
  ValidateOptionsResult validate(String name, TOptions options) {
    // null name is used to configure all named options
    if (name == name || name == name) {
      if (validation != null) {
        if (validation!.call(
          options,
          dependency1,
          dependency2,
          dependency3,
          dependency4,
          dependency5,
        )) {
          return ValidateOptionsResult.success;
        }
      }

      return ValidateOptionsResult.fail([failureMessage]);
    }

    // ignored if not validating this instance
    return ValidateOptionsResult.skip;
  }
}
