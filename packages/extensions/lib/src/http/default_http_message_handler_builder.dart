import 'package:http/http.dart' as http;

import '../dependency_injection/service_provider.dart';
import '../system/exceptions/invalid_operation_exception.dart';
import 'delegating_handler.dart';
import 'http_message_handler.dart';
import 'http_message_handler_builder.dart';

/// Default implementation for building an [HttpMessageHandler] pipeline.
class DefaultHttpMessageHandlerBuilder implements HttpMessageHandlerBuilder {
  DefaultHttpMessageHandlerBuilder(ServiceProvider services)
      : _services = services;

  final ServiceProvider _services;

  @override
  String? name;

  @override
  HttpMessageHandler? primaryHandler;

  final List<DelegatingHandler> _additionalHandlers =
      List<DelegatingHandler>.empty(growable: true);

  @override
  List<DelegatingHandler> get additionalHandlers => _additionalHandlers;

  @override
  ServiceProvider get services => _services;

  @override
  HttpMessageHandler build() {
    if (primaryHandler == null) {
      throw InvalidOperationException(
        message: 'A primary HTTP message handler must be provided.',
      );
    }

    return _createHandlerPipeline(primaryHandler!, _additionalHandlers);
  }

  HttpMessageHandler _createHandlerPipeline(
    HttpMessageHandler primary,
    List<DelegatingHandler> additionalHandlers,
  ) {
    var handler = primary;

    // Build in reverse: last added handler becomes the outermost.
    for (var i = additionalHandlers.length - 1; i >= 0; i--) {
      handler = additionalHandlers[i]..innerHandler = handler;
    }

    return handler;
  }
}

/// Default terminal handler that forwards requests to the dart `http` client.
class DefaultHttpClientHandler implements HttpMessageHandler {
  DefaultHttpClientHandler([http.Client? client])
      : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      _client.send(request);

  @override
  void dispose() => _client.close();
}
