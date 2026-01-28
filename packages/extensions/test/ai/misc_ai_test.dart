import 'dart:typed_data';

import 'package:extensions/ai.dart';
import 'package:extensions/system.dart' show CancellationToken;
import 'package:test/test.dart';

class _TestTool extends AITool {
  _TestTool({String? name}) : super(name: name);
}

class _RecordingFunction extends AIFunction {
  _RecordingFunction() : super(name: 'test');

  AIFunctionArguments? lastArguments;
  CancellationToken? lastToken;

  @override
  Future<Object?> invokeCore(
    AIFunctionArguments arguments, {
    CancellationToken? cancellationToken,
  }) async {
    lastArguments = arguments;
    lastToken = cancellationToken;
    return 'ok';
  }
}

void main() {
  group('AITool', () {
    test('defaults name and toString', () {
      final tool = _TestTool();
      expect(tool.name, 'AITool');
      expect(tool.toString(), 'AITool');
    });
  });

  group('AIFunction', () {
    test('invoke supplies default arguments', () async {
      final function = _RecordingFunction();
      final token = CancellationToken();

      final result = await function.invoke(null, cancellationToken: token);

      expect(result, 'ok');
      expect(function.lastArguments, isNotNull);
      expect(function.lastArguments!.isEmpty, isTrue);
      expect(identical(function.lastToken, token), isTrue);
    });

    test('invoke uses provided arguments', () async {
      final function = _RecordingFunction();
      final args = AIFunctionArguments({'a': 1});

      await function.invoke(args);

      expect(identical(function.lastArguments, args), isTrue);
    });
  });

  group('AIFunctionArguments', () {
    test('copies initial map', () {
      final initial = {'a': 1};
      final args = AIFunctionArguments(initial);

      initial['a'] = 2;

      expect(args['a'], 1);
    });

    test('supports map operations', () {
      final args = AIFunctionArguments();
      args['a'] = 1;
      args['b'] = 2;

      expect(args.length, 2);
      expect(args.remove('a'), 1);
      expect(args.containsKey('a'), isFalse);

      args.clear();
      expect(args.isEmpty, isTrue);
    });

    test('stores context and services', () {
      final args = AIFunctionArguments()
        ..services = Object()
        ..context = {'key': 'value'};

      expect(args.services, isNotNull);
      expect(args.context, {'key': 'value'});
    });
  });

  group('Content helpers', () {
    test('DataContent media type helpers', () {
      final content = DataContent(
        Uint8List.fromList([1, 2, 3]),
        mediaType: 'image/png',
      );

      expect(content.hasTopLevelMediaType('image'), isTrue);
      expect(content.hasTopLevelMediaType('audio'), isFalse);

      final fromUri = DataContent.fromUri('data:image/png;base64,abc');
      expect(fromUri.uri, 'data:image/png;base64,abc');
      expect(fromUri.hasTopLevelMediaType('image'), isFalse);
    });

    test('UriContent media type helpers', () {
      final content = UriContent(
        Uri.parse('https://example.com/image.png'),
        mediaType: 'image/png',
      );

      expect(content.hasTopLevelMediaType('image'), isTrue);
      expect(content.hasTopLevelMediaType('text'), isFalse);
    });
  });

  group('ResponseContinuationToken', () {
    test('toBytes returns original data', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final token = ResponseContinuationToken.fromBytes(bytes);

      expect(token.toBytes(), same(bytes));
      expect(token.toBytes(), equals(bytes));
    });
  });

  group('ChatRole and ChatFinishReason', () {
    test('comparison is case-insensitive', () {
      expect(ChatRole.user, equals(ChatRole('USER')));
      expect(ChatFinishReason.stop, equals(ChatFinishReason('STOP')));
      expect(ChatRole.user.toString(), 'user');
      expect(ChatFinishReason.stop.toString(), 'stop');
    });
  });

  group('ChatToolMode', () {
    test('equality compares types and required function name', () {
      expect(ChatToolMode.auto, equals(const AutoChatToolMode()));
      expect(ChatToolMode.none, equals(const NoneChatToolMode()));

      final anyTool = const RequiredChatToolMode();
      final specificA = ChatToolMode.requireSpecific('toolA');
      final specificB = ChatToolMode.requireSpecific('toolB');

      expect(ChatToolMode.requireAny, equals(anyTool));
      expect(specificA, isNot(equals(specificB)));
    });
  });

  group('ChatResponseFormat', () {
    test('equality compares format types', () {
      expect(ChatResponseFormat.text, equals(const ChatResponseFormatText()));
      expect(ChatResponseFormat.json, equals(const ChatResponseFormatJson()));
    });

    test('json schema equality uses schema name', () {
      final schemaA = ChatResponseFormat.forJsonSchema(
        schema: {'type': 'object'},
        schemaName: 'schema',
      );
      final schemaB = ChatResponseFormat.forJsonSchema(
        schema: {'type': 'string'},
        schemaName: 'schema',
      );
      final schemaC = ChatResponseFormat.forJsonSchema(
        schema: {'type': 'object'},
        schemaName: 'other',
      );

      expect(schemaA, equals(schemaB));
      expect(schemaA, isNot(equals(schemaC)));
    });
  });
}
