import 'dart:async';

import 'package:extensions/ai.dart';
import 'package:extensions/system.dart' show CancellationToken;
import 'package:test/test.dart';

class _RecordingChatClient implements ChatClient {
  _RecordingChatClient({
    ChatResponse? response,
    Stream<ChatResponseUpdate>? stream,
  })  : response = response ?? ChatResponse(),
        stream = stream ?? const Stream<ChatResponseUpdate>.empty();

  final ChatResponse response;
  final Stream<ChatResponseUpdate> stream;
  final List<List<ChatMessage>> calls = [];

  @override
  Future<ChatResponse> getChatResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    calls.add(messages.toList());
    return response;
  }

  @override
  Stream<ChatResponseUpdate> getStreamingChatResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) {
    calls.add(messages.toList());
    return stream;
  }

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {}
}

class _RecordingReducer extends ChatReducer {
  _RecordingReducer(this.result);

  final List<ChatMessage> result;
  List<ChatMessage>? lastMessages;

  @override
  Future<List<ChatMessage>> reduce(
    List<ChatMessage> messages, {
    CancellationToken? cancellationToken,
  }) async {
    lastMessages = messages;
    return result;
  }
}

class _SummaryChatClient implements ChatClient {
  _SummaryChatClient(this.summary);

  final String summary;
  List<ChatMessage>? lastMessages;
  int callCount = 0;

  @override
  Future<ChatResponse> getChatResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    callCount += 1;
    lastMessages = messages.toList();
    return ChatResponse.fromMessage(
      ChatMessage.fromText(ChatRole.assistant, summary),
    );
  }

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
  group('ReducingChatClient', () {
    test('reduces messages before delegating', () async {
      final original = [ChatMessage.fromText(ChatRole.user, 'hello')];
      final reduced = [ChatMessage.fromText(ChatRole.user, 'trimmed')];
      final reducer = _RecordingReducer(reduced);
      final inner = _RecordingChatClient(
        response: ChatResponse.fromMessage(
          ChatMessage.fromText(ChatRole.assistant, 'ok'),
        ),
      );
      final client = ReducingChatClient(inner, reducer: reducer);

      await client.getChatResponse(messages: original);

      expect(reducer.lastMessages, original);
      expect(inner.calls.single, reduced);
    });

    test('reduces messages for streaming', () async {
      final original = [ChatMessage.fromText(ChatRole.user, 'hello')];
      final reduced = [ChatMessage.fromText(ChatRole.user, 'trimmed')];
      final reducer = _RecordingReducer(reduced);
      final inner = _RecordingChatClient();
      final client = ReducingChatClient(inner, reducer: reducer);

      await client.getStreamingChatResponse(messages: original).drain<void>();

      expect(reducer.lastMessages, original);
      expect(inner.calls.single, reduced);
    });
  });

  group('SummarizingChatReducer', () {
    test('summarizes when exceeding max message count', () async {
      final client = _SummaryChatClient('summary text');
      final reducer = SummarizingChatReducer(
        chatClient: client,
        maxMessageCount: 4,
        summarizationPrompt: 'Summarize it',
      );

      final messages = [
        ChatMessage.fromText(ChatRole.user, 'one'),
        ChatMessage.fromText(ChatRole.assistant, 'two'),
        ChatMessage.fromText(ChatRole.user, 'three'),
        ChatMessage.fromText(ChatRole.assistant, 'four'),
        ChatMessage.fromText(ChatRole.user, 'five'),
        ChatMessage.fromText(ChatRole.assistant, 'six'),
      ];

      final reduced = await reducer.reduce(messages);

      expect(client.callCount, 1);
      expect(client.lastMessages, hasLength(5));
      expect(client.lastMessages!.last.role, ChatRole.user);
      expect(client.lastMessages!.last.text, 'Summarize it');

      expect(reduced, hasLength(3));
      expect(reduced.first.role, ChatRole.system);
      expect(
        reduced.first.text,
        'Summary of earlier conversation: summary text',
      );
      expect(identical(reduced[1], messages[4]), isTrue);
      expect(identical(reduced[2], messages[5]), isTrue);
    });

    test('returns original messages when under max count', () async {
      final client = _SummaryChatClient('ignored');
      final reducer = SummarizingChatReducer(
        chatClient: client,
        maxMessageCount: 10,
      );
      final messages = [ChatMessage.fromText(ChatRole.user, 'hi')];

      final reduced = await reducer.reduce(messages);

      expect(client.callCount, 0);
      expect(identical(reduced, messages), isTrue);
    });
  });

  group('AnonymousDelegatingChatClient', () {
    test('uses response handler when provided', () async {
      final inner = _RecordingChatClient();
      final client = AnonymousDelegatingChatClient(
        inner,
        responseHandler: (messages, options, innerClient, cancellationToken) {
          expect(innerClient, same(inner));
          return Future.value(
            ChatResponse.fromMessage(
              ChatMessage.fromText(ChatRole.assistant, 'handled'),
            ),
          );
        },
      );

      final response = await client.getChatResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'hi')],
      );

      expect(response.text, 'handled');
      expect(inner.calls, isEmpty);
    });

    test('uses streaming handler when provided', () async {
      final inner = _RecordingChatClient();
      final client = AnonymousDelegatingChatClient(
        inner,
        streamingResponseHandler:
            (messages, options, innerClient, cancellationToken) async* {
          expect(innerClient, same(inner));
          yield ChatResponseUpdate.fromText(ChatRole.assistant, 'stream');
        },
      );

      final updates = await client.getStreamingChatResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'hi')],
      ).toList();

      expect(updates, hasLength(1));
      expect(updates.single.text, 'stream');
      expect(inner.calls, isEmpty);
    });

    test('delegates when no handlers supplied', () async {
      final inner = _RecordingChatClient(
        response: ChatResponse.fromMessage(
          ChatMessage.fromText(ChatRole.assistant, 'ok'),
        ),
      );
      final client = AnonymousDelegatingChatClient(inner);

      final response = await client.getChatResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'hi')],
      );

      expect(response.text, 'ok');
      expect(inner.calls, hasLength(1));
    });
  });
}
