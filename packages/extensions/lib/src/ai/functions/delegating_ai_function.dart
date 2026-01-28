import '../../system/threading/cancellation_token.dart';
import 'ai_function.dart';
import 'ai_function_arguments.dart';

/// An [AIFunction] that delegates all calls to an inner function.
///
/// Subclass this to create middleware that wraps specific methods
/// while delegating others.
class DelegatingAIFunction extends AIFunction {
  /// Creates a new [DelegatingAIFunction] wrapping [innerFunction].
  DelegatingAIFunction(this.innerFunction)
      : super(
          name: innerFunction.name,
          description: innerFunction.description,
          parametersSchema: innerFunction.parametersSchema,
          returnSchema: innerFunction.returnSchema,
          isStrict: innerFunction.isStrict,
        );

  /// The inner function to delegate to.
  final AIFunction innerFunction;

  @override
  Future<Object?> invokeCore(
    AIFunctionArguments arguments, {
    CancellationToken? cancellationToken,
  }) =>
      innerFunction.invoke(arguments, cancellationToken: cancellationToken);
}
