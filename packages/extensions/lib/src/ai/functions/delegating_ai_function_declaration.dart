import 'ai_function_declaration.dart';

/// An [AIFunctionDeclaration] that delegates its properties to an inner
/// declaration.
///
/// Subclass this to wrap a declaration and override only the properties you
/// need to change.
class DelegatingAIFunctionDeclaration extends AIFunctionDeclaration {
  /// Creates a new [DelegatingAIFunctionDeclaration] wrapping [inner].
  DelegatingAIFunctionDeclaration(this.inner)
    : super(
        name: inner.name,
        description: inner.description,
        parametersSchema: inner.parametersSchema,
        returnSchema: inner.returnSchema,
      );

  /// The inner declaration being wrapped.
  final AIFunctionDeclaration inner;
}
