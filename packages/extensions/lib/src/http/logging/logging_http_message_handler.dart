import 'package:http/http.dart';

import '../../../http.dart';
import '../../../logging.dart';

/// Handles logging of the lifecycle for an HTTP request.
///
/// This handler logs:
/// - Request start (method, URI, headers)
/// - Request completion (status code, elapsed time, headers)
/// - Request failures (exception details, elapsed time)
///
/// Header values can be redacted using the [shouldRedactHeaderValue] function.
class LoggingHttpMessageHandler extends DelegatingHandler {
  /// Creates a new [LoggingHttpMessageHandler] with the specified logger.
  LoggingHttpMessageHandler({
    required this.logger,
    this.shouldRedactHeaderValue,
    HttpMessageHandler? innerHandler,
  }) : super(innerHandler);

  /// The logger used for logging HTTP request information.
  final Logger logger;

  /// A function that determines whether to redact a header value.
  ///
  /// If this function returns `true` for a header name, the header value
  /// will be replaced with "[REDACTED]" in logs.
  final bool Function(String)? shouldRedactHeaderValue;

  /// Redaction placeholder used when a header value should be hidden.
  static const String redactedPlaceholder = '[REDACTED]';

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final stopwatch = Stopwatch()..start();

    _logRequestStart(request);

    try {
      final response = await super.send(request);
      stopwatch.stop();

      _logRequestEnd(request, response, stopwatch.elapsed);

      return response;
    } catch (e) {
      stopwatch.stop();

      _logRequestFailed(request, e, stopwatch.elapsed);

      rethrow;
    }
  }

  void _logRequestStart(BaseRequest request) {
    if (!logger.isEnabled(LogLevel.debug)) {
      return;
    }

    final headers = _formatHeaders(request.headers);
    logger.log(
      logLevel: LogLevel.debug,
      eventId: const EventId(0),
      state: 'HTTP ${request.method} ${request.url}\nHeaders: $headers',
      formatter: (state, error) => state,
    );
  }

  void _logRequestEnd(
    BaseRequest request,
    StreamedResponse response,
    Duration elapsed,
  ) {
    if (!logger.isEnabled(LogLevel.debug)) {
      return;
    }

    final headers = _formatHeaders(response.headers);
    final message =
        'HTTP ${request.method} ${request.url} responded '
        '${response.statusCode} in ${elapsed.inMilliseconds}ms'
        '\nHeaders: $headers';

    logger.log(
      logLevel: LogLevel.debug,
      eventId: const EventId(0),
      state: message,
      formatter: (state, error) => state,
    );
  }

  void _logRequestFailed(
    BaseRequest request,
    Object error,
    Duration elapsed,
  ) {
    if (!logger.isEnabled(LogLevel.error)) {
      return;
    }

    final message =
        'HTTP ${request.method} ${request.url} failed '
        'after ${elapsed.inMilliseconds}ms';

    logger.log(
      logLevel: LogLevel.error,
      eventId: const EventId(0),
      state: message,
      error: error,
      formatter: (state, error) => state,
    );
  }

  /// Formats headers for logging, applying redaction as needed.
  Map<String, String> _formatHeaders(Map<String, String> headers) {
    if (shouldRedactHeaderValue == null) {
      return headers;
    }

    final redacted = <String, String>{};

    for (final entry in headers.entries) {
      if (shouldRedactHeaderValue!(entry.key)) {
        redacted[entry.key] = redactedPlaceholder;
      } else {
        redacted[entry.key] = entry.value;
      }
    }

    return redacted;
  }
}
