import '../abstractions/contents/data_content.dart';
import '../abstractions/image/delegating_image_generator.dart';
import '../abstractions/image/image_generation_options.dart';
import '../abstractions/image/image_generation_request.dart';
import '../abstractions/image/image_generation_response.dart';
import '../abstractions/image/image_generator.dart';
import '../abstractions/image/image_generator_metadata.dart';
import '../telemetry_helpers.dart';

/// A delegating image generator that logs image generation operations to an
/// [Logger].
///
/// Remarks: The provided implementation of [ImageGenerator] is thread-safe
/// for concurrent use so long as the [Logger] employed is also thread-safe
/// for concurrent use. When the employed [Logger] enables [Trace], the
/// contents of prompts and options are logged. These prompts and options may
/// contain sensitive application data. [Trace] is disabled by default and
/// should never be enabled in a production environment. Prompts and options
/// are not logged at other logging levels.
class LoggingImageGenerator extends DelegatingImageGenerator {
  /// Initializes a new instance of the [LoggingImageGenerator] class.
  ///
  /// [innerGenerator] The underlying [ImageGenerator].
  ///
  /// [logger] An [Logger] instance that will be used for all logging.
  LoggingImageGenerator(
    ImageGenerator innerGenerator,
    Logger logger,
  ) :
      _logger = Throw.ifNull(logger),
      _jsonSerializerOptions = AIJsonUtilities.defaultOptions;

  /// An [Logger] instance used for all logging.
  final Logger _logger;

  /// The [JsonSerializerOptions] to use for serialization of state written to
  /// the logger.
  JsonSerializerOptions _jsonSerializerOptions;

  /// Gets or sets JSON serialization options to use when serializing logging
  /// data.
  JsonSerializerOptions jsonSerializerOptions;

  @override
  Future<ImageGenerationResponse> generate(
    ImageGenerationRequest request,
    {ImageGenerationOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    _ = Throw.ifNull(request);
    if (_logger.isEnabled(LogLevel.debug)) {
      if (_logger.isEnabled(LogLevel.trace)) {
        logInvokedSensitive(
          nameof(GenerateAsync),
          request.prompt ?? string.empty,
          asJson(options),
          asJson(this.getService<ImageGeneratorMetadata>()),
        );
      } else {
        logInvoked(nameof(GenerateAsync));
      }
    }
    try {
      var response = await base.generateAsync(request, options, cancellationToken);
      if (_logger.isEnabled(LogLevel.debug)) {
        if (_logger.isEnabled(LogLevel.trace) && response.contents.all((c) => c is! DataContent)) {
          logCompletedSensitive(nameof(GenerateAsync), asJson(response));
        } else {
          logCompleted(nameof(GenerateAsync));
        }
      }
      return response;
    } catch (e, s) {
      if (e is OperationCanceledException) {
        final  = e as OperationCanceledException;
        {
          logInvocationCanceled(nameof(GenerateAsync));
          rethrow;
        }
      } else   if (e is Exception) {
        final ex = e as Exception;
        {
          logInvocationFailed(nameof(GenerateAsync), ex);
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  String asJson<T>(T value) {
    return TelemetryHelpers.asJson(value, _jsonSerializerOptions);
  }

  void logInvoked(String methodName) {
    // TODO: implement LogInvoked
    // C#:
    throw UnimplementedError('LogInvoked not implemented');
  }

  void logInvokedSensitive(
    String methodName,
    String prompt,
    String imageGenerationOptions,
    String imageGeneratorMetadata,
  ) {
    // TODO: implement LogInvokedSensitive
    // C#:
    throw UnimplementedError('LogInvokedSensitive not implemented');
  }

  void logCompleted(String methodName) {
    // TODO: implement LogCompleted
    // C#:
    throw UnimplementedError('LogCompleted not implemented');
  }

  void logCompletedSensitive(String methodName, String imageGenerationResponse, ) {
    // TODO: implement LogCompletedSensitive
    // C#:
    throw UnimplementedError('LogCompletedSensitive not implemented');
  }

  void logInvocationCanceled(String methodName) {
    // TODO: implement LogInvocationCanceled
    // C#:
    throw UnimplementedError('LogInvocationCanceled not implemented');
  }

  void logInvocationFailed(String methodName, Exception error, ) {
    // TODO: implement LogInvocationFailed
    // C#:
    throw UnimplementedError('LogInvocationFailed not implemented');
  }
}
