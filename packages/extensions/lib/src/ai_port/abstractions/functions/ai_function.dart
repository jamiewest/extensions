import 'ai_function_arguments.dart';
import 'ai_function_declaration.dart';
import 'delegating_ai_function_declaration.dart';

/// Represents a function that can be described to an AI service and invoked.
abstract class AFunction extends AFunctionDeclaration {
  /// Initializes a new instance of the [AIFunction] class.
  const AFunction();

  /// Gets the underlying [MethodInfo] that this [AIFunction] might be wrapping.
  ///
  /// Remarks: Provides additional metadata on the function and its signature.
  /// Implementations not wrapping .NET methods may return `null`.
  MethodInfo? get underlyingMethod {
    return null;
  }

  /// Gets a [JsonSerializerOptions] that can be used to marshal function
  /// parameters.
  JsonSerializerOptions get jsonSerializerOptions {
    return AIJsonUtilities.defaultOptions;
  }

  /// Invokes the [AIFunction] and returns its result.
  ///
  /// Returns: The result of the function's execution.
  ///
  /// [arguments] The arguments to pass to the function's invocation.
  ///
  /// [cancellationToken] The [CancellationToken] to monitor for cancellation
  /// requests. The default is [None].
  Future<Object?> invoke({
    AFunctionArguments? arguments,
    CancellationToken? cancellationToken,
  }) {
    return invokeCoreAsync(arguments ?? [], cancellationToken);
  }

  /// Invokes the [AIFunction] and returns its result.
  ///
  /// Returns: The result of the function's execution.
  ///
  /// [arguments] The arguments to pass to the function's invocation.
  ///
  /// [cancellationToken] The [CancellationToken] to monitor for cancellation
  /// requests.
  Future<Object?> invokeCore(
    AFunctionArguments arguments,
    CancellationToken cancellationToken,
  );

  /// Creates a [AIFunctionDeclaration] representation of this [AIFunction] that
  /// can't be invoked.
  ///
  /// Remarks: [AIFunction] derives from [AIFunctionDeclaration], layering on
  /// the ability to invoke the function in addition to describing it.
  /// [AsDeclarationOnly] creates a new object that describes the function but
  /// that can't be invoked.
  ///
  /// Returns: The created instance.
  AFunctionDeclaration asDeclarationOnly() {
    return nonInvocableAFunction(this);
  }
}

class NonInvocableAFunction extends DelegatingAFunctionDeclaration {
  const NonInvocableAFunction(AFunction function);
}
