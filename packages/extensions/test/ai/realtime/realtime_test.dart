import 'dart:async';

import 'package:extensions/ai.dart';
import 'package:extensions/system.dart' show CancellationToken;
import 'package:test/test.dart';

import '../../logging/test_logger.dart';

class _FakeRealtimeSession implements RealtimeClientSession {
  _FakeRealtimeSession({this.options, this.events});

  @override
  final RealtimeSessionOptions? options;

  final List<String>? events;
  RealtimeClientMessage? lastSent;
  bool disposed = false;

  @override
  Future<void> send(
    RealtimeClientMessage message, {
    CancellationToken? cancellationToken,
  }) async {
    lastSent = message;
    events?.add('send');
  }

  @override
  Stream<RealtimeServerMessage> getStreamingResponse({
    CancellationToken? cancellationToken,
  }) async* {
    events?.add('stream');
    yield RealtimeServerMessage(RealtimeServerMessageType.outputTextDelta)
      ..messageId = 'm1';
  }

  @override
  T? getService<T>({Object? key}) => null;

  @override
  Future<void> disposeAsync() async {
    disposed = true;
  }
}

class _FakeRealtimeClient implements RealtimeClient {
  _FakeRealtimeClient({this.session, this.events});

  final _FakeRealtimeSession? session;
  final List<String>? events;
  RealtimeSessionOptions? lastOptions;
  bool disposed = false;

  @override
  Future<RealtimeClientSession> createSession({
    RealtimeSessionOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    lastOptions = options;
    events?.add('inner');
    return session ?? _FakeRealtimeSession(options: options);
  }

  @override
  T? getService<T>({Object? key}) {
    if (key == null && this is T) {
      return this as T;
    }
    return null;
  }

  @override
  void dispose() {
    disposed = true;
  }
}

class _RecordingClient extends DelegatingRealtimeClient {
  _RecordingClient(super.innerClient, this.label, this.events);

  final String label;
  final List<String> events;

  @override
  Future<RealtimeClientSession> createSession({
    RealtimeSessionOptions? options,
    CancellationToken? cancellationToken,
  }) {
    events.add(label);
    return super.createSession(
      options: options,
      cancellationToken: cancellationToken,
    );
  }
}

void main() {
  group('RealtimeServerMessageType', () {
    test('equality is case-insensitive', () {
      expect(
        const RealtimeServerMessageType('ResponseDone'),
        equals(const RealtimeServerMessageType('responsedone')),
      );
      expect(
        RealtimeServerMessageType.responseDone.hashCode,
        equals(const RealtimeServerMessageType('RESPONSEDONE').hashCode),
      );
    });

    test('supports custom values and toString', () {
      const custom = RealtimeServerMessageType('Custom.Type');
      expect(custom.value, 'Custom.Type');
      expect(custom.toString(), 'Custom.Type');
      expect(custom == RealtimeServerMessageType.error, isFalse);
    });
  });

  group('RealtimeSessionKind', () {
    test('well-known values and case-insensitive equality', () {
      expect(RealtimeSessionKind.conversation.value, 'conversation');
      expect(RealtimeSessionKind.transcription.value, 'transcription');
      expect(
        const RealtimeSessionKind('Conversation'),
        equals(RealtimeSessionKind.conversation),
      );
    });
  });

  group('RealtimeAudioFormat', () {
    test('holds media type and sample rate', () {
      final format = RealtimeAudioFormat('audio/pcm', 24000);
      expect(format.mediaType, 'audio/pcm');
      expect(format.sampleRate, 24000);
    });
  });

  group('RealtimeSessionOptions.clone', () {
    test('creates an independent copy of lists', () {
      final original = RealtimeSessionOptions(
        model: 'gpt-realtime',
        instructions: 'be brief',
        outputModalities: ['text', 'audio'],
      );

      final copy = original.clone();
      copy.outputModalities!.add('image');
      copy.model = 'changed';

      expect(original.outputModalities, ['text', 'audio']);
      expect(original.model, 'gpt-realtime');
      expect(copy.instructions, 'be brief');
      expect(copy.sessionKind, RealtimeSessionKind.conversation);
    });
  });

  group('Realtime messages', () {
    test('ErrorRealtimeServerMessage defaults to the error type', () {
      expect(
        ErrorRealtimeServerMessage().type,
        equals(RealtimeServerMessageType.error),
      );
    });

    test('CreateConversationItemRealtimeClientMessage carries the item', () {
      final item = RealtimeConversationItem([TextContent('hi')], id: 'i1');
      final message = CreateConversationItemRealtimeClientMessage(item);
      expect(message.item.id, 'i1');
      expect(message.item.contents, hasLength(1));
    });

    test('SessionUpdateRealtimeClientMessage carries options', () {
      final options = RealtimeSessionOptions(model: 'm');
      final message = SessionUpdateRealtimeClientMessage(options);
      expect(message.options.model, 'm');
    });
  });

  group('RealtimeClientBuilder', () {
    test('applies middleware so the first use is outermost', () async {
      final events = <String>[];
      final inner = _FakeRealtimeClient(events: events);

      final client = inner
          .asBuilder()
          .use((c) => _RecordingClient(c, 'outer', events))
          .use((c) => _RecordingClient(c, 'inner-wrapper', events))
          .build();

      await client.createSession();

      expect(events, ['outer', 'inner-wrapper', 'inner']);
    });

    test('build with no middleware returns the inner client', () {
      final inner = _FakeRealtimeClient();
      expect(inner.asBuilder().build(), same(inner));
    });
  });

  group('LoggingRealtimeClient', () {
    test('wraps the session and delegates send/stream', () async {
      final sessionEvents = <String>[];
      final session = _FakeRealtimeSession(events: sessionEvents);
      final inner = _FakeRealtimeClient(session: session);
      final logger = TestLogger('realtime');

      final client = LoggingRealtimeClient(inner, logger: logger);
      final loggingSession = await client.createSession();

      expect(loggingSession, isA<LoggingRealtimeClientSession>());

      await loggingSession.send(
        InputAudioBufferCommitRealtimeClientMessage()..messageId = 'c1',
      );
      expect(
          session.lastSent, isA<InputAudioBufferCommitRealtimeClientMessage>());

      final received = await loggingSession.getStreamingResponse().toList();
      expect(received, hasLength(1));
      expect(sessionEvents, ['send', 'stream']);

      expect(
        logger.loggedMessages.any((e) => e.message.contains('send')),
        isTrue,
      );
    });

    test('disposeAsync delegates to the inner session', () async {
      final session = _FakeRealtimeSession();
      final inner = _FakeRealtimeClient(session: session);
      final client = LoggingRealtimeClient(inner, logger: TestLogger('rt'));

      final loggingSession = await client.createSession();
      await loggingSession.disposeAsync();

      expect(session.disposed, isTrue);
    });

    test('dispose and getService delegate to the inner client', () {
      final inner = _FakeRealtimeClient();
      final client = LoggingRealtimeClient(inner, logger: TestLogger('rt'));

      expect(client.getService<_FakeRealtimeClient>(), same(inner));
      client.dispose();
      expect(inner.disposed, isTrue);
    });
  });
}
