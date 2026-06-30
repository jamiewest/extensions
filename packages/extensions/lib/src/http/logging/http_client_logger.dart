import 'package:http/http.dart';

import '../../../http.dart' show HttpClientFactory;

import '../http_client_factory.dart' show HttpClientFactory;

/// An abstraction for custom HTTP request logging for named HTTP client
/// instances returned by [HttpClientFactory].
abstract class HttpClientLogger {
  /// Logs before sending an HTTP request.
  Object? logRequestStart(BaseRequest request) => null;

  /// Logs after receiving an HTTP response.
  void logRequestStop(
      Object? context, BaseRequest response, Duration elapsed) {}

  /// Logs the exception happened while sending an HTTP request.
  void logRequestFailed(Object? context, BaseRequest? request,
      Exception exception, Duration elapsed) {}
}
