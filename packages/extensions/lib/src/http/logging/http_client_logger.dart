import 'package:http/http.dart';

/// An abstraction for custom HTTP request logging for a named [HttpClient]
/// instances returned by [HttpClientFactory].
abstract class HttpClientLogger {
  /// Logs before sending an HTTP request.
  Object? logRequestStart(BaseRequest request) {}

  /// Logs after receiving an HTTP response.
  void logRequestStop(
      Object? context, BaseRequest response, Duration elapsed) {}

  /// Logs the exception happened while sending an HTTP request.
  void logRequestFailed(Object? context, BaseRequest? request,
      Exception exception, Duration elapsed) {}
}
