import '../../system/threading/cancellation_token.dart';
import 'image_generator.dart';

/// An [ImageGenerator] that delegates all calls to an inner generator.
///
/// Subclass this to create middleware that wraps specific methods
/// while delegating others.
///
/// This is an experimental feature.
abstract class DelegatingImageGenerator implements ImageGenerator {
  /// Creates a new [DelegatingImageGenerator] wrapping [innerGenerator].
  DelegatingImageGenerator(this.innerGenerator);

  /// The inner generator to delegate to.
  final ImageGenerator innerGenerator;

  @override
  Future<ImageGenerationResponse> generate({
    required ImageGenerationRequest request,
    ImageGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      innerGenerator.generate(
        request: request,
        options: options,
        cancellationToken: cancellationToken,
      );

  @override
  T? getService<T>({Object? key}) =>
      innerGenerator.getService<T>(key: key);

  @override
  void dispose() => innerGenerator.dispose();
}
