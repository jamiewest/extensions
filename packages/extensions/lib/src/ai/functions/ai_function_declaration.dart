import 'package:extensions/annotations.dart';

import '../tools/ai_tool.dart';

/// Represents a function that can be described to an AI service.
///
/// [AIFunctionDeclaration] is the base class for [AIFunction], which adds the
/// ability to invoke the function. Components can type-test an [AITool] for
/// [AIFunctionDeclaration] to determine whether it can be described as a
/// function, and for [AIFunction] to determine whether it can be invoked.
@Source(
  name: 'AIFunctionDeclaration.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Functions/',
)
abstract class AIFunctionDeclaration extends AITool {
  /// Creates a new [AIFunctionDeclaration].
  AIFunctionDeclaration({
    required super.name,
    super.description,
    this.parametersSchema,
    this.returnSchema,
  });

  /// The JSON schema describing the function's input parameters.
  ///
  /// When `null`, consuming clients should assume the `{}` schema — any JSON
  /// input is admissible.
  final Map<String, dynamic>? parametersSchema;

  /// The JSON schema describing the function's return value.
  ///
  /// `null` when the function returns void or has no return schema.
  final Map<String, dynamic>? returnSchema;
}
