import 'package:extensions/ai.dart';
import 'package:extensions/system.dart' show CancellationToken;
import 'package:test/test.dart';

class _TestFunction extends AIFunction {
  _TestFunction(String name, this._result) : super(name: name);

  final Object? _result;
  int invokeCount = 0;
  AIFunctionArguments? lastArguments;

  @override
  Future<Object?> invokeCore(
    AIFunctionArguments arguments, {
    CancellationToken? cancellationToken,
  }) async {
    invokeCount++;
    lastArguments = arguments;
    return _result;
  }
}

class _FakeSession implements RealtimeClientSession {
  _FakeSession(this._messages);

  final List<RealtimeServerMessage> _messages;

  @override
  final RealtimeSessionOptions? options = null;

  final List<RealtimeClientMessage> sent = <RealtimeClientMessage>[];
  bool disposed = false;

  @override
  Future<void> send(
    RealtimeClientMessage message, {
    CancellationToken? cancellationToken,
  }) async =>
      sent.add(message);

  @override
  Stream<RealtimeServerMessage> getStreamingResponse({
    CancellationToken? cancellationToken,
  }) async* {
    for (final message in _messages) {
      yield message;
    }
  }

  @override
  T? getService<T>({Object? key}) => null;

  @override
  Future<void> disposeAsync() async => disposed = true;
}

class _FakeClient implements RealtimeClient {
  _FakeClient(this._session);

  final RealtimeClientSession _session;

  @override
  Future<RealtimeClientSession> createSession({
    RealtimeSessionOptions? options,
    CancellationToken? cancellationToken,
  }) async =>
      _session;

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {}
}

ResponseOutputItemRealtimeServerMessage _functionCallMessage(
  List<FunctionCallContent> calls,
) =>
    ResponseOutputItemRealtimeServerMessage(
      RealtimeServerMessageType.responseOutputItemDone,
    )..item = RealtimeConversationItem(calls.cast<AIContent>());

void main() {
  group('FunctionInvokingRealtimeClientSession', () {
    test('invokes the matching tool and sends the result back', () async {
      final tool = _TestFunction('getWeather', 'sunny');
      final message = _functionCallMessage([
        FunctionCallContent(
          callId: 'c1',
          name: 'getWeather',
          arguments: <String, Object?>{'city': 'Paris'},
        ),
      ]);
      final session = _FakeSession([message]);
      final client = FunctionInvokingRealtimeClient(_FakeClient(session))
        ..additionalTools = [tool];

      final fiSession = await client.createSession();
      final received = await fiSession.getStreamingResponse().toList();

      // The server message is still surfaced to the caller.
      expect(received, hasLength(1));
      expect(tool.invokeCount, equals(1));

      // A conversation-item (with the result) and a response request are sent.
      expect(session.sent, hasLength(2));
      expect(
          session.sent[0], isA<CreateConversationItemRealtimeClientMessage>());
      expect(session.sent[1], isA<CreateResponseRealtimeClientMessage>());

      final item =
          (session.sent[0] as CreateConversationItemRealtimeClientMessage).item;
      final result = item.contents.single as FunctionResultContent;
      expect(result.callId, equals('c1'));
      expect(result.result, equals('sunny'));
    });

    test('passes through messages that contain no function calls', () async {
      final plain =
          RealtimeServerMessage(RealtimeServerMessageType.outputTextDelta);
      final session = _FakeSession([plain]);
      final client = FunctionInvokingRealtimeClient(_FakeClient(session));

      final fiSession = await client.createSession();
      final received = await fiSession.getStreamingResponse().toList();

      expect(received, equals([plain]));
      expect(session.sent, isEmpty);
    });

    test('an unknown function sends a not-found result by default', () async {
      final message = _functionCallMessage([
        FunctionCallContent(callId: 'c1', name: 'missing'),
      ]);
      final session = _FakeSession([message]);
      final client = FunctionInvokingRealtimeClient(_FakeClient(session));

      final fiSession = await client.createSession();
      final received = await fiSession.getStreamingResponse().toList();

      expect(received, hasLength(1));
      expect(session.sent, hasLength(2));
    });

    test('terminateOnUnknownCalls stops without sending results', () async {
      final message = _functionCallMessage([
        FunctionCallContent(callId: 'c1', name: 'missing'),
      ]);
      final session = _FakeSession([message]);
      final client = FunctionInvokingRealtimeClient(_FakeClient(session))
        ..terminateOnUnknownCalls = true;

      final fiSession = await client.createSession();
      final received = await fiSession.getStreamingResponse().toList();

      expect(received, hasLength(1));
      expect(session.sent, isEmpty);
    });

    test('getService and disposeAsync forward to the inner session', () async {
      final session = _FakeSession(const []);
      final client = FunctionInvokingRealtimeClient(_FakeClient(session));

      final fiSession = await client.createSession();
      await fiSession.disposeAsync();

      expect(session.disposed, isTrue);
    });
  });
}
