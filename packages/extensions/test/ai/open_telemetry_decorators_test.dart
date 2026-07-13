import 'package:extensions/ai.dart';
import 'package:extensions/system.dart' hide equals;
import 'package:test/test.dart';

class _FakeSpeechToTextClient implements SpeechToTextClient {
  final List<String> calls = [];
  bool disposed = false;
  Object? throwOnGetText;

  @override
  Future<SpeechToTextResponse> getText({
    required Stream<List<int>> stream,
    SpeechToTextOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    calls.add('getText');
    final error = throwOnGetText;
    if (error != null) {
      throw error;
    }
    return SpeechToTextResponse.fromText('transcribed');
  }

  @override
  Stream<SpeechToTextResponse> getStreamingText({
    required Stream<List<int>> stream,
    SpeechToTextOptions? options,
    CancellationToken? cancellationToken,
  }) async* {
    calls.add('getStreamingText');
    yield SpeechToTextResponse.fromText('chunk-1');
    yield SpeechToTextResponse.fromText('chunk-2');
  }

  @override
  T? getService<T>({Object? key}) => this is T ? this as T : null;

  @override
  void dispose() => disposed = true;
}

class _FakeHostedFileClient implements HostedFileClient {
  final List<String> calls = [];
  bool disposed = false;

  @override
  Future<HostedFileContent> upload(
    Stream<List<int>> content, {
    String? mediaType,
    String? fileName,
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    calls.add('upload');
    return HostedFileContent(fileId: 'file-1', mediaType: mediaType);
  }

  @override
  Stream<List<int>> download(
    String fileId, {
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) async* {
    calls.add('download:$fileId');
    yield [1, 2, 3];
  }

  @override
  Future<HostedFileContent?> getFile(
    String fileId, {
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    calls.add('getFile:$fileId');
    return HostedFileContent(fileId: fileId);
  }

  @override
  Stream<HostedFileContent> listFiles({
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) async* {
    calls.add('listFiles');
    yield HostedFileContent(fileId: 'file-1');
  }

  @override
  Future<bool> delete(
    String fileId, {
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    calls.add('delete:$fileId');
    return true;
  }

  @override
  T? getService<T>({Object? key}) => this is T ? this as T : null;

  @override
  void dispose() => disposed = true;
}

class _FakeRealtimeClientSession implements RealtimeClientSession {
  final List<Object> sent = [];
  bool disposed = false;

  @override
  RealtimeSessionOptions? get options =>
      RealtimeSessionOptions(model: 'rt-model', voice: 'alloy');

  @override
  Future<void> send(
    RealtimeClientMessage message, {
    CancellationToken? cancellationToken,
  }) async {
    sent.add(message);
  }

  @override
  Stream<RealtimeServerMessage> getStreamingResponse({
    CancellationToken? cancellationToken,
  }) async* {
    yield RealtimeServerMessage(RealtimeServerMessageType.rawContentOnly);
  }

  @override
  T? getService<T>({Object? key}) => this is T ? this as T : null;

  @override
  Future<void> disposeAsync() async => disposed = true;
}

class _FakeRealtimeClient implements RealtimeClient {
  _FakeRealtimeClient(this.session);

  final _FakeRealtimeClientSession session;
  int createSessionCalls = 0;

  @override
  Future<RealtimeClientSession> createSession({
    RealtimeSessionOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    createSessionCalls++;
    return session;
  }

  @override
  T? getService<T>({Object? key}) => this is T ? this as T : null;

  @override
  void dispose() {}
}

void main() {
  group('OpenTelemetrySpeechToTextClient', () {
    test('forwards getText and returns the inner response', () async {
      final inner = _FakeSpeechToTextClient();
      final client = OpenTelemetrySpeechToTextClient(
        inner,
        modelId: 'whisper-1',
        system: 'openai',
      );

      final response = await client.getText(
        stream: const Stream<List<int>>.empty(),
      );

      expect(inner.calls, ['getText']);
      expect(response.text, 'transcribed');
    });

    test('forwards getStreamingText and yields all updates', () async {
      final inner = _FakeSpeechToTextClient();
      final client = OpenTelemetrySpeechToTextClient(inner);

      final updates = await client
          .getStreamingText(stream: const Stream<List<int>>.empty())
          .toList();

      expect(inner.calls, ['getStreamingText']);
      expect(updates.map((u) => u.text), ['chunk-1', 'chunk-2']);
    });

    test('propagates errors from the inner client', () async {
      final inner = _FakeSpeechToTextClient()
        ..throwOnGetText = StateError('boom');
      final client = OpenTelemetrySpeechToTextClient(inner);

      await expectLater(
        client.getText(stream: const Stream<List<int>>.empty()),
        throwsStateError,
      );
    });

    test('builder extension registers the decorator', () {
      final inner = _FakeSpeechToTextClient();
      final client = SpeechToTextClientBuilder(inner)
          .useOpenTelemetry(modelId: 'whisper-1')
          .build();

      expect(client, isA<OpenTelemetrySpeechToTextClient>());
    });

    test('dispose forwards to the inner client', () {
      final inner = _FakeSpeechToTextClient();
      OpenTelemetrySpeechToTextClient(inner).dispose();

      expect(inner.disposed, isTrue);
    });
  });

  group('OpenTelemetryHostedFileClient', () {
    test('forwards all file operations', () async {
      final inner = _FakeHostedFileClient();
      final client = OpenTelemetryHostedFileClient(inner, system: 'openai');

      final uploaded = await client.upload(
        const Stream<List<int>>.empty(),
        mediaType: 'text/plain',
        fileName: 'notes.txt',
      );
      final bytes = await client.download('file-1').toList();
      final info = await client.getFile('file-1');
      final listed = await client.listFiles().toList();
      final deleted = await client.delete('file-1');

      expect(uploaded.fileId, 'file-1');
      expect(bytes.single, [1, 2, 3]);
      expect(info?.fileId, 'file-1');
      expect(listed.single.fileId, 'file-1');
      expect(deleted, isTrue);
      expect(inner.calls, [
        'upload',
        'download:file-1',
        'getFile:file-1',
        'listFiles',
        'delete:file-1',
      ]);
    });

    test('builder extension registers the decorator', () {
      final inner = _FakeHostedFileClient();
      final client = HostedFileClientBuilder(inner).useOpenTelemetry().build();

      expect(client, isA<OpenTelemetryHostedFileClient>());
    });
  });

  group('OpenTelemetryRealtimeClient', () {
    test('wraps created sessions and forwards send/receive', () async {
      final innerSession = _FakeRealtimeClientSession();
      final inner = _FakeRealtimeClient(innerSession);
      final client = OpenTelemetryRealtimeClient(
        inner,
        modelId: 'rt-model',
        system: 'openai',
      );

      final session = await client.createSession();
      expect(session, isA<OpenTelemetryRealtimeClientSession>());
      expect(inner.createSessionCalls, 1);

      final message = RealtimeClientMessage()..messageId = 'm-1';
      await session.send(message);
      expect(innerSession.sent.single, same(message));

      final received = await session.getStreamingResponse().toList();
      expect(received, hasLength(1));

      expect(session.options?.model, 'rt-model');

      await session.disposeAsync();
      expect(innerSession.disposed, isTrue);
    });

    test('builder extension registers the decorator', () {
      final inner = _FakeRealtimeClient(_FakeRealtimeClientSession());
      final client = RealtimeClientBuilder(inner).useOpenTelemetry().build();

      expect(client, isA<OpenTelemetryRealtimeClient>());
    });
  });
}
