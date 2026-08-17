import 'package:extensions/dependency_injection.dart';
import 'package:extensions/http.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

class _RecordingHandler extends DelegatingHandler {
  _RecordingHandler(this.label);

  final String label;
}

void main() {
  group('HttpClientBuilder.addAsKeyed', () {
    test('registers the named client as a keyed BaseClient', () {
      final services = ServiceCollection();
      services
          .addHttpClient('github')
          .addAsKeyed(lifetime: ServiceLifetime.transient);

      final provider = services.buildServiceProvider();
      final client = provider.getRequiredKeyedService<http.BaseClient>(
        'github',
      );

      expect(client, isA<http.BaseClient>());
    });

    test('removeAsKeyed removes the keyed registration', () {
      final services = ServiceCollection();
      services
          .addHttpClient('github')
          .addAsKeyed(lifetime: ServiceLifetime.transient)
          .removeAsKeyed();

      final provider = services.buildServiceProvider();

      expect(provider.getKeyedService<http.BaseClient>('github'), isNull);
    });

    test('addAsKeyed twice does not duplicate the registration', () {
      final services = ServiceCollection();
      final builder = services.addHttpClient('github')
        ..addAsKeyed(lifetime: ServiceLifetime.transient)
        ..addAsKeyed(lifetime: ServiceLifetime.transient);

      final keyed = builder.services.where(
        (descriptor) =>
            descriptor.serviceType == http.BaseClient &&
            descriptor.serviceKey == 'github',
      );

      expect(keyed, hasLength(1));
    });
  });

  group('HttpClientBuilder.configureAdditionalHttpMessageHandlers', () {
    test('runs after earlier handler registrations', () {
      final services = ServiceCollection();
      List<String>? observed;
      services
          .addHttpClient('api')
          .addHttpMessageHandler((sp) => _RecordingHandler('auth'))
          .addHttpMessageHandler((sp) => _RecordingHandler('retry'))
          .configureAdditionalHttpMessageHandlers((handlers, sp) {
            observed = handlers
                .whereType<_RecordingHandler>()
                .map((handler) => handler.label)
                .toList();
          });

      final provider = services.buildServiceProvider();
      provider.getRequiredService<HttpMessageHandlerFactory>().createHandler(
        'api',
      );

      expect(observed, ['auth', 'retry']);
    });
  });
}
