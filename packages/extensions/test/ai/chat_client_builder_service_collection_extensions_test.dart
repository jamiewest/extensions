import 'package:extensions/ai.dart';
import 'package:extensions/dependency_injection.dart';
import 'package:extensions/system.dart' show CancellationToken;
import 'package:test/test.dart';

class _TestChatClient implements ChatClient {
  @override
  Future<ChatResponse> getResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async =>
      ChatResponse.fromMessage(
        ChatMessage.fromText(ChatRole.assistant, 'ok'),
      );

  @override
  Stream<ChatResponseUpdate> getStreamingResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      const Stream<ChatResponseUpdate>.empty();

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {}
}

void main() {
  group('ChatClientBuilderServiceCollectionExtensions', () {
    test('addChatClient registers a ChatClient descriptor and returns builder',
        () {
      final services = ServiceCollection();

      final builder = services.addChatClient((_) => _TestChatClient());

      expect(services, hasLength(1));
      expect(services.first.serviceType, ChatClient);
      expect(services.first.lifetime, ServiceLifetime.singleton);
      expect(builder, isA<ChatClientBuilder>());
    });

    test('addChatClient respects the provided lifetime', () {
      final services = ServiceCollection();

      services.addChatClient(
        (_) => _TestChatClient(),
        ServiceLifetime.transient,
      );

      expect(services.first.lifetime, ServiceLifetime.transient);
    });

    test('builder builds client using the factory with the service provider',
        () {
      final services = ServiceCollection();
      final provider = services.buildServiceProvider();

      final builder = services.addChatClient((_) => _TestChatClient());
      final client = builder.build(provider);

      expect(client, isA<_TestChatClient>());
    });

    test('registered descriptor resolves ChatClient via service provider', () {
      final services = ServiceCollection()
        ..addChatClient((_) => _TestChatClient());
      final provider = services.buildServiceProvider();

      final client = provider.getService<ChatClient>();

      expect(client, isA<_TestChatClient>());
    });
  });
}
