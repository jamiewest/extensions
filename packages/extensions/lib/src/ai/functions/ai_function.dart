import '../../system/threading/cancellation_token.dart';
import 'ai_function_arguments.dart';
import 'ai_function_declaration.dart';

/// Represents a function that can be described to and invoked by an AI model.
abstract class AIFunction extends AIFunctionDeclaration {
  /// Creates a new [AIFunction].
  AIFunction({
    required super.name,
    super.description,
    super.parametersSchema,
    super.returnSchema,
    this.isStrict,
  });

  /// Whether the function requires strict schema adherence.
  final bool? isStrict;

  /// Invokes the function with the given [arguments].
  Future<Object?> invoke(
    AIFunctionArguments? arguments, {
    CancellationToken? cancellationToken,
  }) =>
      invokeCore(
        arguments ?? AIFunctionArguments(),
        cancellationToken: cancellationToken,
      );

  /// Core implementation of function invocation.
  Future<Object?> invokeCore(
    AIFunctionArguments arguments, {
    CancellationToken? cancellationToken,
  });
}
