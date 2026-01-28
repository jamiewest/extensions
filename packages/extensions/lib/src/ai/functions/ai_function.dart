import '../../system/threading/cancellation_token.dart';
import 'ai_function_arguments.dart';
import '../tools/ai_tool.dart';

/// Represents a function that can be invoked by an AI model.
abstract class AIFunction extends AITool {
  /// Creates a new [AIFunction].
  AIFunction({
    required super.name,
    super.description,
    this.parametersSchema,
    this.returnSchema,
    this.isStrict,
  });

  /// The JSON schema describing the function's parameters.
  final Map<String, dynamic>? parametersSchema;

  /// The JSON schema describing the function's return value.
  final Map<String, dynamic>? returnSchema;

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
