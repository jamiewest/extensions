import 'dart:async';

import 'package:extensions/ai.dart';
import 'package:extensions/dependency_injection.dart' show ServiceProvider;
import 'package:extensions/system.dart' show CancellationToken;
import 'package:test/test.dart';

class _RecordingSpeechToTextClient implements SpeechToTextClient {
  _RecordingSpeechToTextClient({this.events});

  final List<String>? events;
  SpeechToTextOptions? lastOptions;
  bool disposed = false;

  @override
  Future<SpeechToTextResponse> getText({
    required Stream<List<int>> stream,
    SpeechToTextOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    events?.add('inner');
    lastOptions = options;
    return SpeechToTextResponse.fromText('ok');
  }

  @override
  Stream<SpeechToTextResponse> getStreamingText({
    required Stream<List<int>> stream,
    SpeechToTextOptions? options,
    CancellationToken? cancellationToken,
  }) async* {
    lastOptions = options;
    yield SpeechToTextResponse.fromText('stream');
  }

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {
    disposed = true;
  }
}

class _RecordingWrapper extends DelegatingSpeechToTextClient {
  _RecordingWrapper(super.innerClient, this.label, this.events);

  final String label;
  final List<String> events;

  @override
  Future<SpeechToTextResponse> getText({
    required Stream<List<int>> stream,
    SpeechToTextOptions? options,
    CancellationToken? cancellationToken,
  }) {
    events.add(label);
    return super.getText(
      stream: stream,
      options: options,
      cancellationToken: cancellationToken,
    );
  }
}

class _TestServiceProvider implements ServiceProvider {
  @override
  Object? getServiceFromType(Type type) => null;
}

void main() {
  group('SpeechToTextClientBuilder', () {
    test('build applies middleware in reverse order', () async {
      final events = <String>[];
      final inner = _RecordingSpeechToTextClient(events: events);
      final builder = SpeechToTextClientBuilder(inner)
        ..use((client) => _RecordingWrapper(client, 'first', events))
        ..use((client) => _RecordingWrapper(client, 'second', events));

      final client = builder.build();
      await client.getText(stream: const Stream<List<int>>.empty());

      expect(events, ['first', 'second', 'inner']);
    });

    test('fromFactory receives provided services', () {
      ServiceProvider? captured;
      final provider = _TestServiceProvider();
      final builder = SpeechToTextClientBuilder.fromFactory((services) {
        captured = services;
        return _RecordingSpeechToTextClient();
      });

      builder.build(provider);

      expect(identical(captured, provider), isTrue);
    });
  });

  group('ConfigureOptionsSpeechToTextClient', () {
    test('applies configuration to options', () async {
      final inner = _RecordingSpeechToTextClient();
      final client = ConfigureOptionsSpeechToTextClient(
        inner,
        configure: (options) {
          options.modelId = 'configured-model';
          return options;
        },
      );

      await client.getText(stream: const Stream<List<int>>.empty());

      expect(inner.lastOptions?.modelId, 'configured-model');
    });
  });

  group('DelegatingSpeechToTextClient', () {
    test('dispose delegates to inner client', () {
      final inner = _RecordingSpeechToTextClient();
      final wrapper = _RecordingWrapper(inner, 'outer', []);

      wrapper.dispose();

      expect(inner.disposed, isTrue);
    });
  });

  group('SpeechToTextResponse', () {
    test('fromText creates text content', () {
      final response = SpeechToTextResponse.fromText('hello');
      expect(response.text, 'hello');
      expect(response.toString(), 'hello');
      expect(response.contents, hasLength(1));
      expect(response.contents.first, isA<TextContent>());
    });
  });

  group('SpeechToTextClientMetadata', () {
    test('stores provider info', () {
      final meta = SpeechToTextClientMetadata(
        providerName: 'Provider',
        providerUri: Uri.parse('https://example.com'),
        defaultModelId: 'model',
      );

      expect(meta.providerName, 'Provider');
      expect(meta.providerUri, Uri.parse('https://example.com'));
      expect(meta.defaultModelId, 'model');
    });
  });
}
