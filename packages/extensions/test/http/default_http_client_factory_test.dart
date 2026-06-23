import 'package:extensions/dependency_injection.dart';
import 'package:extensions/http.dart';
import 'package:extensions/options.dart';
import 'package:extensions/src/http/default_http_client_factory.dart';
import 'package:extensions/system.dart' hide equals;
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

class _FakeHandler implements HttpMessageHandler {
  bool disposed = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
      http.StreamedResponse(Stream<List<int>>.empty(), 200);

  @override
  void dispose() => disposed = true;
}

class _FakeHandlerFactory implements HttpMessageHandlerFactory {
  final List<_FakeHandler> created = <_FakeHandler>[];

  @override
  HttpMessageHandler createHandler([String? name = Options.defaultName]) {
    final handler = _FakeHandler();
    created.add(handler);
    return handler;
  }
}

DefaultHttpClientFactory _buildFactory(
  _FakeHandlerFactory handlerFactory, {
  void Function(HttpClientFactoryOptions)? configure,
}) {
  final services = ServiceCollection();
  if (configure != null) {
    services.configure<HttpClientFactoryOptions>(
      HttpClientFactoryOptions.new,
      configure,
    );
  } else {
    services.addOptions<HttpClientFactoryOptions>(HttpClientFactoryOptions.new);
  }

  final sp = services.buildServiceProvider();
  final monitor =
      sp.getRequiredService<OptionsMonitor<HttpClientFactoryOptions>>();
  return DefaultHttpClientFactory(sp, handlerFactory, monitor);
}

void main() {
  group('DefaultHttpClientFactory', () {
    test('createClient returns a client', () {
      final factory = _buildFactory(_FakeHandlerFactory());

      expect(factory.createClient(), isA<http.BaseClient>());
    });

    test('reuses a single handler for the same client name', () {
      final handlerFactory = _FakeHandlerFactory();
      final factory = _buildFactory(handlerFactory);

      factory.createClient('api');
      factory.createClient('api');

      expect(handlerFactory.created, hasLength(1));
    });

    test('creates a distinct handler per client name', () {
      final handlerFactory = _FakeHandlerFactory();
      final factory = _buildFactory(handlerFactory);

      factory.createClient('a');
      factory.createClient('b');

      expect(handlerFactory.created, hasLength(2));
    });

    test('applies configured httpClientActions to the new client', () {
      http.BaseClient? configured;
      final factory = _buildFactory(
        _FakeHandlerFactory(),
        configure: (options) => options.httpClientActions.add(
          (client, services) => configured = client,
        ),
      );

      final client = factory.createClient();

      expect(configured, same(client));
    });

    test('a closed client throws when used and leaves the handler alive', () {
      final handlerFactory = _FakeHandlerFactory();
      final factory = _buildFactory(handlerFactory);

      final client = factory.createClient()..close();

      expect(
        () => client.send(http.Request('GET', Uri.parse('http://example'))),
        throwsA(isA<ObjectDisposedException>()),
      );
      expect(handlerFactory.created.single.disposed, isFalse);
    });

    test('rotates an expired handler and disposes the previous one', () async {
      final handlerFactory = _FakeHandlerFactory();
      final factory = _buildFactory(
        handlerFactory,
        configure: (options) =>
            options.handlerLifetime = const Duration(milliseconds: 1),
      );

      factory.createClient('x');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      factory.createClient('x');

      expect(handlerFactory.created, hasLength(2));
      expect(handlerFactory.created.first.disposed, isTrue);
    });

    test('suppressHandlerDispose keeps the rotated handler alive', () async {
      final handlerFactory = _FakeHandlerFactory();
      final factory = _buildFactory(
        handlerFactory,
        configure: (options) => options
          ..handlerLifetime = const Duration(milliseconds: 1)
          ..suppressHandlerDispose = true,
      );

      factory.createClient('x');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      factory.createClient('x');

      expect(handlerFactory.created, hasLength(2));
      expect(handlerFactory.created.first.disposed, isFalse);
    });
  });
}
