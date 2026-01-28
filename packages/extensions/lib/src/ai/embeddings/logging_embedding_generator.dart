import 'dart:async';
import 'dart:convert';

import '../../logging/log_level.dart';
import '../../logging/logger.dart';
import '../../logging/logger_extensions.dart';
import '../../system/exceptions/operation_cancelled_exception.dart';
import '../../system/threading/cancellation_token.dart';
import 'delegating_embedding_generator.dart';
import 'embedding_generation_options.dart';
import 'generated_embeddings.dart';

/// A delegating embedding generator that logs operations to a [Logger].
class LoggingEmbeddingGenerator extends DelegatingEmbeddingGenerator {
  /// Creates a new [LoggingEmbeddingGenerator].
  LoggingEmbeddingGenerator(
    super.innerGenerator, {
    required Logger logger,
  }) : _logger = logger;

  final Logger _logger;

  /// The [JsonEncoder] used to serialize log data.
  JsonEncoder jsonEncoder = const JsonEncoder.withIndent('  ');

  @override
  Future<GeneratedEmbeddings> generateEmbeddings({
    required Iterable<String> values,
    EmbeddingGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    if (_logger.isEnabled(LogLevel.debug)) {
      _logger.logDebug('generateEmbeddings invoked.');
    }

    if (_logger.isEnabled(LogLevel.trace)) {
      _logger.logTrace(
        'generateEmbeddings invoked. '
        'Values count: ${values.length}. '
        'Options: '
        '${options != null ? _asJson(_optionsToMap(options)) : 'null'}.',
      );
    }

    try {
      final result = await super.generateEmbeddings(
        values: values,
        options: options,
        cancellationToken: cancellationToken,
      );

      if (_logger.isEnabled(LogLevel.debug)) {
        _logger.logDebug('generateEmbeddings completed.');
      }

      if (_logger.isEnabled(LogLevel.trace)) {
        _logger.logTrace(
          'generateEmbeddings completed. '
          'Embeddings count: ${result.length}.',
        );
      }

      return result;
    } on OperationCanceledException {
      if (_logger.isEnabled(LogLevel.debug)) {
        _logger.logDebug('generateEmbeddings canceled.');
      }
      rethrow;
    } catch (e) {
      _logger.logError('generateEmbeddings failed.', error: e);
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

  static Map<String, Object?> _optionsToMap(
    EmbeddingGenerationOptions options,
  ) => {
        if (options.modelId != null) 'modelId': options.modelId,
        if (options.dimensions != null) 'dimensions': options.dimensions,
      };
}
