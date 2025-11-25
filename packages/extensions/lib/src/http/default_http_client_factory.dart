import 'package:http/http.dart' as http;

import '../dependency_injection/service_provider.dart';
import '../options/options.dart';
import '../options/options_monitor.dart';
import '../system/exceptions/object_disposed_exception.dart';
import 'http_client_factory.dart';
import 'http_client_factory_options.dart';
import 'http_message_handler.dart';
import 'http_message_handler_factory.dart';

class _HandlerEntry {
  _HandlerEntry(this.handler, this.expiration);

  final HttpMessageHandler handler;
  final DateTime? expiration;
}

/// Default implementation of [HttpClientFactory] modeled after .NET's
/// IHttpClientFactory.
class DefaultHttpClientFactory implements HttpClientFactory {
  DefaultHttpClientFactory(
    this._services,
    this._messageHandlerFactory,
    this._optionsMonitor,
  );

  final ServiceProvider _services;
  final HttpMessageHandlerFactory _messageHandlerFactory;
  final OptionsMonitor<HttpClientFactoryOptions> _optionsMonitor;

  final Map<String, _HandlerEntry> _activeHandlers = <String, _HandlerEntry>{};

  @override
  @override
  http.BaseClient createClient([String? name = Options.defaultName]) {
    var clientName = name ?? Options.defaultName;
    var options = _optionsMonitor.get(clientName);
    var handler = _getHandler(clientName, options);
    var client = _HttpMessageHandlerClient(handler);

    for (var action in options.httpClientActions) {
      action(client, _services);
    }

    return client;
  }

  HttpMessageHandler _getHandler(
    String name,
    HttpClientFactoryOptions options,
  ) {
    var now = DateTime.now();
    var entry = _activeHandlers[name];

    if (entry != null && !_isExpired(entry, now)) {
      return entry.handler;
    }

    var newHandler = _messageHandlerFactory.createHandler(name);
    var lifetime = options.handlerLifetime;
    DateTime? expiration;
    if (lifetime > Duration.zero) {
      expiration = now.add(lifetime);
    }

    _activeHandlers[name] = _HandlerEntry(newHandler, expiration);

    if (entry != null && !options.suppressHandlerDispose) {
      entry.handler.dispose();
    }

    return newHandler;
  }

  bool _isExpired(_HandlerEntry entry, DateTime now) {
    var expiration = entry.expiration;
    if (expiration == null) {
      return false;
    }
    return expiration.isBefore(now);
  }
}

class _HttpMessageHandlerClient extends http.BaseClient {
  _HttpMessageHandlerClient(this._handler);

  final HttpMessageHandler _handler;
  bool _disposed = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (_disposed) {
      throw ObjectDisposedException(objectName: 'HttpClient');
    }
    return _handler.send(request);
  }

  @override
  void close() {
    _disposed = true;
    // The handler lifetime is managed by the factory, so we intentionally
    // do not dispose the handler here.
  }
}
