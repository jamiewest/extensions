import 'ai_function.dart';
import 'ai_function_arguments.dart';

/// Provides an optional base class for an [AIFunction] that passes through
/// calls to another instance.
class DelegatingAFunction extends AFunction {
  /// Initializes a new instance of the [DelegatingAIFunction] class as a
  /// wrapper around `innerFunction`.
  ///
  /// [innerFunction] The inner AI function to which all calls are delegated by
  /// default.
  const DelegatingAFunction(AFunction innerFunction)
    : innerFunction = Throw.ifNull(innerFunction);

  /// Gets the inner [AIFunction].
  final AFunction innerFunction;

  String get name {
    return innerFunction.name;
  }

  String get description {
    return innerFunction.description;
  }

  JsonElement get jsonSchema {
    return innerFunction.jsonSchema;
  }

  JsonElement? get returnJsonSchema {
    return innerFunction.returnJsonSchema;
  }

  JsonSerializerOptions get jsonSerializerOptions {
    return innerFunction.jsonSerializerOptions;
  }

  MethodInfo? get underlyingMethod {
    return innerFunction.underlyingMethod;
  }

  Map<String, Object?> get additionalProperties {
    return innerFunction.additionalProperties;
  }

  @override
  String toString() {
    return innerFunction.toString();
  }

  @override
  Future<Object?> invokeCore(
    AFunctionArguments arguments,
    CancellationToken cancellationToken,
  ) {
    return innerFunction.invokeAsync(arguments, cancellationToken);
  }

  @override
  Object? getService(Type serviceType, {Object? serviceKey}) {
    _ = Throw.ifNull(serviceType);
    return serviceKey == null && serviceType.isInstanceOfType(this)
        ? this
        : innerFunction.getService(serviceType, serviceKey);
  }
}
