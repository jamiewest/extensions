import 'image_generation_options.dart';
import 'image_generation_request.dart';
import 'image_generation_response.dart';
import 'image_generator.dart';

/// Provides an optional base class for an [ImageGenerator] that passes
/// through calls to another instance.
///
/// Remarks: This is recommended as a base type when building generators that
/// can be chained in any order around an underlying [ImageGenerator]. The
/// default implementation simply passes each call to the inner generator
/// instance.
class DelegatingImageGenerator implements ImageGenerator {
  /// Initializes a new instance of the [DelegatingImageGenerator] class.
  ///
  /// [innerGenerator] The wrapped generator instance.
  const DelegatingImageGenerator(ImageGenerator innerGenerator)
    : innerGenerator = Throw.ifNull(innerGenerator);

  /// Gets the inner [ImageGenerator].
  final ImageGenerator innerGenerator;

  /// Provides a mechanism for releasing unmanaged resources.
  ///
  /// [disposing] `true` if being called from [Dispose]; otherwise, `false`.
  @override
  void dispose({bool? disposing}) {
    if (disposing) {
      innerGenerator.dispose();
    }
  }

  @override
  Future<ImageGenerationResponse> generate(
    ImageGenerationRequest request, {
    ImageGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) {
    return innerGenerator.generateAsync(request, options, cancellationToken);
  }

  @override
  Object? getService(Type serviceType, {Object? serviceKey}) {
    _ = Throw.ifNull(serviceType);
    return serviceKey == null && serviceType.isInstanceOfType(this)
        ? this
        : innerGenerator.getService(serviceType, serviceKey);
  }
}
