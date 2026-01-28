import 'dart:async';
import 'dart:convert';

import '../../logging/log_level.dart';
import '../../logging/logger.dart';
import '../../logging/logger_extensions.dart';
import '../../system/exceptions/operation_cancelled_exception.dart';
import '../../system/threading/cancellation_token.dart';
import 'delegating_image_generator.dart';
import 'image_generator.dart';

/// A delegating image generator that logs operations to a [Logger].
///
/// This is an experimental feature.
class LoggingImageGenerator extends DelegatingImageGenerator {
  /// Creates a new [LoggingImageGenerator].
  LoggingImageGenerator(
    super.innerGenerator, {
    required Logger logger,
  }) : _logger = logger;

  final Logger _logger;

  /// The [JsonEncoder] used to serialize log data.
  JsonEncoder jsonEncoder = const JsonEncoder.withIndent('  ');

  @override
  Future<ImageGenerationResponse> generate({
    required ImageGenerationRequest request,
    ImageGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    if (_logger.isEnabled(LogLevel.debug)) {
      _logger.logDebug('generate invoked.');
    }

    if (_logger.isEnabled(LogLevel.trace)) {
      _logger.logTrace(
        'generate invoked. '
        'Prompt: ${request.prompt ?? 'null'}. '
        'Options: '
        '${options != null ? _asJson(_optionsToMap(options)) : 'null'}.',
      );
    }

    try {
      final result = await super.generate(
        request: request,
        options: options,
        cancellationToken: cancellationToken,
      );

      if (_logger.isEnabled(LogLevel.debug)) {
        _logger.logDebug('generate completed.');
      }

      if (_logger.isEnabled(LogLevel.trace)) {
        _logger.logTrace(
          'generate completed. '
          'Contents count: ${result.contents.length}.',
        );
      }

      return result;
    } on OperationCanceledException {
      if (_logger.isEnabled(LogLevel.debug)) {
        _logger.logDebug('generate canceled.');
      }
      rethrow;
    } catch (e) {
      _logger.logError('generate failed.', error: e);
      rethrow;
    }
  }

  String _asJson(Object? value) {
    try {
      return jsonEncoder.convert(value);
    } catch (_) {
      return value.toString();
    }
  }

  static Map<String, Object?> _optionsToMap(ImageGenerationOptions options) => {
        if (options.modelId != null) 'modelId': options.modelId,
        if (options.count != null) 'count': options.count,
        if (options.imageWidth != null) 'imageWidth': options.imageWidth,
        if (options.imageHeight != null) 'imageHeight': options.imageHeight,
      };
}
