import 'default_http_client_factory.dart' show DefaultHttpClientFactory;
import 'http_message_handler_builder.dart';

/// Used by the [DefaultHttpClientFactory] to apply additional configuration
/// to the [HttpMessageHandlerBuilder] immediately before calling `build`.
abstract class HttpMessageHandlerBuilderFilter {
  /// Applies additional configuration to the [HttpMessageHandlerBuilder].
  ///
  /// The [next] parameter represents the next filter in the pipeline, or the
  /// final handler building step if this is the last filter.
  ///
  /// Filters can execute code before and after calling [next]:
  ///
  /// ```dart
  /// class MyFilter extends HttpMessageHandlerBuilderFilter {
  ///   @override
  ///   void configure(
  ///     void Function(HttpMessageHandlerBuilder) next,
  ///     HttpMessageHandlerBuilder builder,
  ///   ) {
  ///     // Execute code before building
  ///     print('Building handler for: ${builder.name}');
  ///
  ///     // Call the next filter in the pipeline
  ///     next(builder);
  ///
  ///     // Execute code after building
  ///     print('Handler built for: ${builder.name}');
  ///   }
  /// }
  /// ```
  void configure(
    void Function(HttpMessageHandlerBuilder) next,
    HttpMessageHandlerBuilder builder,
  );
}
