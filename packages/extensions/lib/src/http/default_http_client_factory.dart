import 'dart:async';

import 'package:http/http.dart' as http;

import '../dependency_injection/service_provider.dart';
import '../options/options.dart';
import '../options/options_monitor.dart';
import '../system/disposable.dart';
import '../system/exceptions/object_disposed_exception.dart';
import 'active_handler_tracking_entry.dart';
import 'expired_handler_tracking_entry.dart';
import 'http_client_factory.dart';
import 'http_client_factory_options.dart';
import 'http_message_handler.dart';
import 'http_message_handler_factory.dart';
import 'lifetime_tracking_http_message_handler.dart';

/// Default implementation of [HttpClientFactory] modeled after .NET's
/// IHttpClientFactory.
///
/// Handlers are cached per client name and rotated after their
/// configured lifetime. Rotated handlers are not disposed while
/// requests are in flight; a timer-driven cleanup cycle disposes them
/// once idle. Upstream uses weak references and finalizers for this;
/// the timer approach also works on the web.
class DefaultHttpClientFactory implements HttpClientFactory, Disposable {
  /// Creates a new [DefaultHttpClientFactory].
  ///
  /// [_cleanupInterval] controls how often rotated handlers are checked
  /// for disposal once requests have drained.
  DefaultHttpClientFactory(
    this._services,
    this._messageHandlerFactory,
    this._optionsMonitor, {
    this._cleanupInterval = const Duration(seconds: 10),
  });

  final ServiceProvider _services;
  final HttpMessageHandlerFactory _messageHandlerFactory;
  final OptionsMonitor<HttpClientFactoryOptions> _optionsMonitor;
  final Duration _cleanupInterval;

  final Map<String, ActiveHandlerTrackingEntry> _activeHandlers =
      <String, ActiveHandlerTrackingEntry>{};
  final List<ExpiredHandlerTrackingEntry> _expiredHandlers =
      <ExpiredHandlerTrackingEntry>[];
  Timer? _cleanupTimer;
  bool _disposed = false;

  @override
  http.BaseClient createClient([String? name = Options.defaultName]) {
    if (_disposed) {
      throw ObjectDisposedException(objectName: 'DefaultHttpClientFactory');
    }

    var clientName = name ?? Options.defaultName;
    var options = _optionsMonitor.get(clientName);
    var handler = _getHandler(clientName, options);
    var client = _HttpMessageHandlerClient(handler);

    for (var action in options.httpClientActions) {
      action(client, _services);
    }

    return client;
  }

  /// The number of rotated handlers awaiting disposal.
  int get expiredHandlerCount => _expiredHandlers.length;

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    for (final entry in _expiredHandlers) {
      entry.disposeInner();
    }
    _expiredHandlers.clear();
    for (final entry in _activeHandlers.values) {
      entry.handler.disposeInner();
    }
    _activeHandlers.clear();
  }

  HttpMessageHandler _getHandler(
    String name,
    HttpClientFactoryOptions options,
  ) {
    var now = DateTime.now();
    var entry = _activeHandlers[name];

    if (entry != null && !entry.isExpired(now)) {
      return entry.handler;
    }

    final newHandler = LifetimeTrackingHttpMessageHandler(
      _messageHandlerFactory.createHandler(name),
    );
    var lifetime = options.handlerLifetime;
    DateTime? expiration;
    if (lifetime > Duration.zero) {
      expiration = now.add(lifetime);
    }

    _activeHandlers[name] = ActiveHandlerTrackingEntry(
      name: name,
      handler: newHandler,
      expiration: expiration,
    );

    if (entry != null && !options.suppressHandlerDispose) {
      _expiredHandlers.add(ExpiredHandlerTrackingEntry(entry));
      _cleanupExpiredHandlers();
    }

    return newHandler;
  }

  void _cleanupExpiredHandlers() {
    _expiredHandlers.removeWhere((entry) {
      if (entry.canDispose) {
        entry.disposeInner();
        return true;
      }
      return false;
    });

    if (_expiredHandlers.isEmpty) {
      _cleanupTimer?.cancel();
      _cleanupTimer = null;
    } else {
      _cleanupTimer ??= Timer.periodic(
        _cleanupInterval,
        (_) => _cleanupExpiredHandlers(),
      );
    }
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
