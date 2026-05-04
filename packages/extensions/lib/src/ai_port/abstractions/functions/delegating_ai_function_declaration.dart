import 'ai_function_declaration.dart';

/// Provides an optional base class for an [AIFunctionDeclaration] that passes
/// through calls to another instance.
class DelegatingAFunctionDeclaration extends AFunctionDeclaration {
  /// Initializes a new instance of the [DelegatingAIFunctionDeclaration] class
  /// as a wrapper around `innerFunction`.
  ///
  /// [innerFunction] The inner AI function to which all calls are delegated by
  /// default.
  const DelegatingAFunctionDeclaration(AFunctionDeclaration innerFunction)
    : innerFunction = Throw.ifNull(innerFunction);

  /// Gets the inner [AIFunctionDeclaration].
  final AFunctionDeclaration innerFunction;

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

  Map<String, Object?> get additionalProperties {
    return innerFunction.additionalProperties;
  }

  @override
  String toString() {
    return innerFunction.toString();
  }

  @override
  Object? getService(Type serviceType, {Object? serviceKey}) {
    _ = Throw.ifNull(serviceType);
    return serviceKey == null && serviceType.isInstanceOfType(this)
        ? this
        : innerFunction.getService(serviceType, serviceKey);
  }
}
