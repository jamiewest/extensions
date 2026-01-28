import '../../system/threading/cancellation_token.dart';
import 'ai_function.dart';
import 'ai_function_arguments.dart';

/// A factory for creating [AIFunction] instances from simple callbacks.
///
/// This provides a convenient way to create [AIFunction] instances
/// without needing to subclass [AIFunction] directly.
class AIFunctionFactory {
  AIFunctionFactory._();

  /// Creates an [AIFunction] from a callback function.
  ///
  /// [name] is the name of the function.
  /// [description] is a description of what the function does.
  /// [callback] is the function to invoke.
  /// [parametersSchema] is the JSON schema describing the parameters.
  /// [returnSchema] is the JSON schema describing the return value.
  /// [isStrict] indicates whether strict schema adherence is required.
  static AIFunction create({
    required String name,
    required Future<Object?> Function(
      AIFunctionArguments arguments, {
      CancellationToken? cancellationToken,
    }) callback,
    String? description,
    Map<String, dynamic>? parametersSchema,
    Map<String, dynamic>? returnSchema,
    bool? isStrict,
  }) =>
      _CallbackAIFunction(
        name: name,
        description: description,
        parametersSchema: parametersSchema,
        returnSchema: returnSchema,
        isStrict: isStrict,
        callback: callback,
      );
}

class _CallbackAIFunction extends AIFunction {
  _CallbackAIFunction({
    required super.name,
    super.description,
    super.parametersSchema,
    super.returnSchema,
    super.isStrict,
    required this.callback,
  });

  final Future<Object?> Function(
    AIFunctionArguments arguments, {
    CancellationToken? cancellationToken,
  }) callback;

  @override
  Future<Object?> invokeCore(
    AIFunctionArguments arguments, {
    CancellationToken? cancellationToken,
  }) =>
      callback(arguments, cancellationToken: cancellationToken);
}
