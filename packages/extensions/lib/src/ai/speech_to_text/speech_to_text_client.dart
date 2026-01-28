import 'dart:async';

import '../../system/disposable.dart';
import '../../system/threading/cancellation_token.dart';
import '../additional_properties_dictionary.dart';
import '../ai_content.dart';
import '../text_content.dart';
import '../usage_details.dart';

/// Options for speech-to-text requests.
///
/// This is an experimental feature.
class SpeechToTextOptions {
  /// Creates a new [SpeechToTextOptions].
  SpeechToTextOptions({
    this.modelId,
    this.speechLanguage,
    this.speechSampleRate,
    this.textLanguage,
    this.additionalProperties,
  });

  /// The model to use for transcription.
  String? modelId;

  /// The language of the input speech.
  String? speechLanguage;

  /// The audio sampling rate in Hz.
  int? speechSampleRate;

  /// The desired output language.
  String? textLanguage;

  /// Additional properties.
  AdditionalPropertiesDictionary? additionalProperties;

  /// Creates a deep copy of this [SpeechToTextOptions].
  SpeechToTextOptions clone() => SpeechToTextOptions(
        modelId: modelId,
        speechLanguage: speechLanguage,
        speechSampleRate: speechSampleRate,
        textLanguage: textLanguage,
        additionalProperties: additionalProperties != null
            ? Map.of(additionalProperties!)
            : null,
      );
}

/// Represents a speech-to-text response.
///
/// This is an experimental feature.
class SpeechToTextResponse {
  /// Creates a new [SpeechToTextResponse].
  SpeechToTextResponse({
    List<AIContent>? contents,
    this.startTime,
    this.endTime,
    this.responseId,
    this.modelId,
    this.rawRepresentation,
    this.additionalProperties,
    this.usage,
  }) : contents = contents ?? [];

  /// Creates a response from a text string.
  SpeechToTextResponse.fromText(String text)
      : contents = [TextContent(text)],
        startTime = null,
        endTime = null,
        responseId = null,
        modelId = null,
        rawRepresentation = null,
        additionalProperties = null,
        usage = null;

  /// The content items.
  final List<AIContent> contents;

  /// The start time of the speech segment.
  Duration? startTime;

  /// The end time of the speech segment.
  Duration? endTime;

  /// A unique response identifier.
  String? responseId;

  /// The model that generated this response.
  String? modelId;

  /// The underlying implementation-specific object.
  Object? rawRepresentation;

  /// Additional properties.
  AdditionalPropertiesDictionary? additionalProperties;

  /// Usage details.
  UsageDetails? usage;

  /// Gets concatenated text from all [TextContent] items.
  String get text => contents
      .whereType<TextContent>()
      .map((c) => c.text)
      .join();

  @override
  String toString() => text;
}

/// Represents a speech-to-text client.
///
/// This is an experimental feature.
abstract class SpeechToTextClient implements Disposable {
  /// Transcribes the given audio [stream].
  Future<SpeechToTextResponse> getText({
    required Stream<List<int>> stream,
    SpeechToTextOptions? options,
    CancellationToken? cancellationToken,
  });

  /// Transcribes the given audio [stream] as a stream of
  /// updates.
  Stream<SpeechToTextResponse> getStreamingText({
    required Stream<List<int>> stream,
    SpeechToTextOptions? options,
    CancellationToken? cancellationToken,
  });

  /// Gets a service of the specified type.
  T? getService<T>({Object? key}) => null;
}
