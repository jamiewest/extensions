import 'dart:typed_data';

import '../data_content.dart';
import 'text_to_speech_response.dart';
import 'text_to_speech_response_update.dart';

/// Combines [TextToSpeechResponseUpdate] instances into a
/// [TextToSpeechResponse].
///
/// Upstream accumulates every content item into the response's content
/// list; the Dart [TextToSpeechResponse] instead carries a single
/// [TextToSpeechResponse.audio] [DataContent], so audio chunks that carry
/// in-memory bytes are
/// concatenated (the media type is taken from the first chunk). When any
/// chunk lacks bytes — a URI-only [DataContent] — the last chunk wins.
///
/// This is an experimental feature.
extension TextToSpeechResponseUpdatesExtensions
    on Iterable<TextToSpeechResponseUpdate> {
  /// Combines the updates into a single [TextToSpeechResponse].
  TextToSpeechResponse toTextToSpeechResponse() {
    final accumulator = _TextToSpeechResponseAccumulator();
    for (final update in this) {
      accumulator.add(update);
    }
    return accumulator.response;
  }
}

/// Combines a stream of [TextToSpeechResponseUpdate] instances into a
/// [TextToSpeechResponse].
extension TextToSpeechResponseUpdatesStreamExtensions
    on Stream<TextToSpeechResponseUpdate> {
  /// Drains the stream and combines the updates into a single
  /// [TextToSpeechResponse].
  Future<TextToSpeechResponse> toTextToSpeechResponse() async {
    final accumulator = _TextToSpeechResponseAccumulator();
    await for (final update in this) {
      accumulator.add(update);
    }
    return accumulator.response;
  }
}

class _TextToSpeechResponseAccumulator {
  final _audioChunks = <DataContent>[];

  final _response = TextToSpeechResponse();

  TextToSpeechResponse get response {
    _response.audio = _combineAudio();
    return _response;
  }

  void add(TextToSpeechResponseUpdate update) {
    if (update.responseId != null) {
      _response.responseId = update.responseId;
    }
    if (update.modelId != null) {
      _response.modelId = update.modelId;
    }
    if (update.audio != null) {
      _audioChunks.add(update.audio!);
    }
    if (update.rawRepresentation != null) {
      _response.rawRepresentation = update.rawRepresentation;
    }
    final props = update.additionalProperties;
    if (props != null) {
      (_response.additionalProperties ??= {}).addAll(props);
    }
  }

  DataContent? _combineAudio() {
    if (_audioChunks.isEmpty) {
      return null;
    }
    if (_audioChunks.length == 1 || _audioChunks.any((c) => c.data == null)) {
      return _audioChunks.last;
    }
    final builder = BytesBuilder(copy: false);
    for (final chunk in _audioChunks) {
      builder.add(chunk.data!);
    }
    return DataContent(
      builder.takeBytes(),
      mediaType: _audioChunks.first.mediaType,
      name: _audioChunks.first.name,
    );
  }
}
