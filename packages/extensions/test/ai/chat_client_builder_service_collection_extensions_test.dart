import 'package:extensions/ai.dart';
import 'package:extensions/dependency_injection.dart'
    show ServiceCollection, ServiceProvider;
import 'package:extensions/system.dart' show CancellationToken;
import 'package:test/test.dart';

class _TestServiceProvider implements ServiceProvider {
  @override
  Object? getServiceFromType(Type type) => null;
}

class _TestChatClient implements ChatClient {
  @override
  Future<ChatResponse> getChatResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async =>
      ChatResponse.fromMessage(
        ChatMessage.fromText(ChatRole.assistant, 'ok'),
      );

  @override
  Stream<ChatResponseUpdate> getStreamingChatResponse({
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
    test('addChatClient returns builder without mutating collection', () {
      final services = ServiceCollection();
      ServiceProvider? captured;

      final builder = services.addChatClient((provider) {
        captured = provider;
        return _TestChatClient();
      });

      expect(services, isEmpty);
      expect(builder, isA<ChatClientBuilder>());

      final provider = _TestServiceProvider();
      final client = builder.build(provider);

      expect(identical(captured, provider), isTrue);
      expect(client, isA<_TestChatClient>());
    });
  });
}
