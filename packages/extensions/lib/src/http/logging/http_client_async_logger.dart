import 'dart:io' show HttpClient;

import 'package:http/http.dart';

import '../../../http.dart' show HttpClientFactory;
import '../../../system.dart';
import '../http_client_factory.dart' show HttpClientFactory;
import 'http_client_logger.dart';

/// An abstraction for asyncronous custom HTTP request logging for a
/// named [HttpClient] instances returned by [HttpClientFactory].
abstract class HttpClientAsyncLogger extends HttpClientLogger {
  Future<Object?> logRequestStartAsync(
    BaseRequest request,
    CancellationToken? cancellationToken,
  );

  Future<void> logRequestStopAsync(
    Object? context,
    BaseRequest response,
    Duration elapsed,
    CancellationToken? cancellationToken,
  );

  Future<void> logRequestFailedAsync(
    Object? context,
    BaseRequest? request,
    Exception exception,
    Duration elapsed,
    CancellationToken? cancellationToken,
  );
}
