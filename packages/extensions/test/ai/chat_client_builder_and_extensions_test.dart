import 'dart:async';

import 'package:extensions/ai.dart';
import 'package:extensions/system.dart';
import 'package:test/test.dart';

class _RecordingChatClient implements ChatClient {
  _RecordingChatClient({
    this.events,
    ChatResponse? response,
    Stream<ChatResponseUpdate>? stream,
  })  : response = response ?? ChatResponse(),
        stream = stream ?? const Stream<ChatResponseUpdate>.empty();

  final List<String>? events;
  final ChatResponse response;
  final Stream<ChatResponseUpdate> stream;

  Iterable<ChatMessage>? lastMessages;
  ChatOptions? lastOptions;
  CancellationToken? lastCancellationToken;
  bool disposed = false;

  @override
  Future<ChatResponse> getChatResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    events?.add('inner');
    lastMessages = messages;
    lastOptions = options;
    lastCancellationToken = cancellationToken;
    return response;
  }

  @override
  Stream<ChatResponseUpdate> getStreamingChatResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) {
    lastMessages = messages;
    lastOptions = options;
    lastCancellationToken = cancellationToken;
    return stream;
  }

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {
    disposed = true;
  }
}

class _RecordingWrapper extends DelegatingChatClient {
  _RecordingWrapper(super.innerClient, this.label, this.events);

  final String label;
  final List<String> events;

  @override
  Future<ChatResponse> getChatResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) {
    events.add(label);
    return super.getChatResponse(
      messages: messages,
      options: options,
      cancellationToken: cancellationToken,
    );
  }
}

void main() {
  group('ChatClientBuilder', () {
    test('build applies middleware in reverse order', () async {
      final events = <String>[];
      final inner = _RecordingChatClient(events: events);
      final builder = ChatClientBuilder(inner)
        ..use((client) => _RecordingWrapper(client, 'first', events))
        ..use((client) => _RecordingWrapper(client, 'second', events));

      final client = builder.build();
      await client.getChatResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'hi')],
      );

      expect(events, ['first', 'second', 'inner']);
    });
  });

  group('ChatClientExtensions', () {
    test('getChatResponseFromText sends a user message', () async {
      final client = _RecordingChatClient();
      final options = ChatOptions(modelId: 'model');
      final token = CancellationToken();

      await client.getChatResponseFromText(
        'Hello',
        options: options,
        cancellationToken: token,
      );

      final messages = client.lastMessages!.toList();
      expect(messages, hasLength(1));
      expect(messages.first.role, ChatRole.user);
      expect(messages.first.text, 'Hello');
      expect(identical(client.lastOptions, options), isTrue);
      expect(identical(client.lastCancellationToken, token), isTrue);
    });

    test('getStreamingChatResponseFromMessage forwards the message', () {
      final client = _RecordingChatClient();
      final message = ChatMessage.fromText(ChatRole.user, 'Hi');

      client.getStreamingChatResponseFromMessage(message);

      final messages = client.lastMessages!.toList();
      expect(messages, [message]);
    });
  });

  group('DelegatingChatClient', () {
    test('dispose delegates to inner client', () {
      final inner = _RecordingChatClient();
      final wrapper = _RecordingWrapper(inner, 'outer', []);

      wrapper.dispose();

      expect(inner.disposed, isTrue);
    });
  });
}
