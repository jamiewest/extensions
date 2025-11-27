import 'package:http/http.dart' as http;

import '../dependency_injection/service_provider.dart';
import 'http_message_handler_builder.dart';

typedef HttpMessageHandlerBuilderAction = void Function(
  HttpMessageHandlerBuilder builder,
  ServiceProvider services,
);

typedef HttpClientAction = void Function(
  http.BaseClient client,
  ServiceProvider services,
);

/// Options used by the default HTTP client factory.
class HttpClientFactoryOptions {
  /// The lifespan of a handler instance. A zero or negative duration disables
  /// expiration and reuses the same handler.
  Duration handlerLifetime = const Duration(minutes: 2);

  /// Prevents disposal of previous handlers when rotating them.
  ///
  /// This mirrors .NET's SuppressHandlerScope and keeps the handler alive for
  /// external ownership scenarios.
  bool suppressHandlerDispose = false;

  /// Gets or sets a function that determines whether to redact the HTTP header
  /// value before logging.
  ///
  /// The function accepts a header name and returns `true` if the header value
  /// should be redacted; otherwise, `false`.
  ///
  /// Common headers to redact include:
  /// - Authorization
  /// - Cookie
  /// - Set-Cookie
  /// - X-Api-Key
  /// - X-Auth-Token
  bool Function(String headerName)? shouldRedactHeaderValue;

  /// Disables the default logging for HTTP requests made using clients created
  /// by this factory.
  bool suppressDefaultLogging = false;

  /// Actions that configure the message handler pipeline.
  final List<HttpMessageHandlerBuilderAction> httpMessageHandlerBuilderActions =
      <HttpMessageHandlerBuilderAction>[];

  /// Actions that configure the final HTTP client instance.
  final List<HttpClientAction> httpClientActions =
      <HttpClientAction>[];
}
