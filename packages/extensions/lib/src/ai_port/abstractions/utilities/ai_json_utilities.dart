import '../contents/ai_content.dart';

/// Provides a collection of utility methods for marshalling JSON data.
extension AJsonUtilities on JsonSerializerOptions {
  /// Adds a custom content type to the polymorphic configuration for
  /// [AIContent].
  ///
  /// [options] The options instance to configure.
  ///
  /// [typeDiscriminatorId] The type discriminator id for the content type.
  ///
  /// [TContent] The custom content type to configure.
  void addAIContentType<TContent>(
    String typeDiscriminatorId, {
    Type? contentType,
  }) {
    _ = Throw.ifNull(options);
    _ = Throw.ifNull(typeDiscriminatorId);
    addAIContentTypeChain(
      options,
      typeof(TContent),
      typeDiscriminatorId,
      checkBuiltIn: true,
    );
  }
}
