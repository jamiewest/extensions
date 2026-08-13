import 'dart:async';

import 'package:extensions/dependency_injection.dart';
import 'package:extensions/http.dart';
import 'package:extensions/options.dart';
import 'package:extensions/src/http/default_http_client_factory.dart';
import 'package:extensions/system.dart' hide equals;
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

class _ControlledHandler implements HttpMessageHandler {
  bool disposed = false;
  Completer<http.StreamedResponse>? pending;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final completer = pending;
    if (completer != null) {
      return completer.future;
    }
    return Future.value(
      http.StreamedResponse(const Stream<List<int>>.empty(), 200),
    );
  }

  @override
  void dispose() => disposed = true;
}

class _ControlledHandlerFactory implements HttpMessageHandlerFactory {
  final List<_ControlledHandler> created = <_ControlledHandler>[];

  @override
  HttpMessageHandler createHandler([String? name = Options.defaultName]) {
    final handler = _ControlledHandler();
    created.add(handler);
    return handler;
  }
}

DefaultHttpClientFactory _buildFactory(
  _ControlledHandlerFactory handlerFactory, {
  required Duration handlerLifetime,
  Duration cleanupInterval = const Duration(milliseconds: 5),
}) {
  final services = ServiceCollection()
    ..configure<HttpClientFactoryOptions>(
      HttpClientFactoryOptions.new,
      (options) => options.handlerLifetime = handlerLifetime,
    );
  final sp = services.buildServiceProvider();
  final monitor = sp
      .getRequiredService<OptionsMonitor<HttpClientFactoryOptions>>();
  return DefaultHttpClientFactory(
    sp,
    handlerFactory,
    monitor,
    cleanupInterval: cleanupInterval,
  );
}

void main() {
  group('DefaultHttpClientFactory handler lifetime tracking', () {
    test('rotation with no in-flight requests disposes immediately', () async {
      final handlerFactory = _ControlledHandlerFactory();
      final factory = _buildFactory(
        handlerFactory,
        handlerLifetime: const Duration(milliseconds: 1),
      );

      factory.createClient('x');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      factory.createClient('x');

      expect(handlerFactory.created, hasLength(2));
      expect(handlerFactory.created.first.disposed, isTrue);
      expect(factory.expiredHandlerCount, 0);
    });

    test('rotation defers disposal while a request is in flight', () async {
      final handlerFactory = _ControlledHandlerFactory();
      final factory = _buildFactory(
        handlerFactory,
        handlerLifetime: const Duration(milliseconds: 1),
      );

      final client = factory.createClient('x');
      final firstHandler = handlerFactory.created.single;
      final gate = Completer<http.StreamedResponse>();
      firstHandler.pending = gate;
      final inFlight = client.send(
        http.Request('GET', Uri.parse('http://example')),
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));
      factory.createClient('x');

      expect(handlerFactory.created, hasLength(2));
      expect(firstHandler.disposed, isFalse);
      expect(factory.expiredHandlerCount, 1);

      gate.complete(
        http.StreamedResponse(const Stream<List<int>>.empty(), 200),
      );
      await inFlight;
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(firstHandler.disposed, isTrue);
      expect(factory.expiredHandlerCount, 0);
    });

    test('dispose cancels tracking and disposes all handlers', () async {
      final handlerFactory = _ControlledHandlerFactory();
      final factory = _buildFactory(
        handlerFactory,
        handlerLifetime: const Duration(milliseconds: 1),
      );

      factory.createClient('x');
      factory.createClient('y');
      factory.dispose();

      expect(
        handlerFactory.created.every((handler) => handler.disposed),
        isTrue,
      );
      expect(
        () => factory.createClient('x'),
        throwsA(isA<ObjectDisposedException>()),
      );
    });
  });
}
