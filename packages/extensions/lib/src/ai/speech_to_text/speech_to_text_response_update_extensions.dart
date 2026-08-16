import 'package:extensions/annotations.dart';

import '../ai_content.dart';
import '../text_content.dart';
import '../usage_content.dart';
import '../usage_details.dart';
import 'speech_to_text_client.dart';
import 'speech_to_text_response_update.dart';

/// Combines [SpeechToTextResponseUpdate] instances into a
/// [SpeechToTextResponse].
///
/// This is an experimental feature.
@Source(
  name: 'SpeechToTextResponseUpdateExtensions.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/SpeechToText/',
)
extension SpeechToTextResponseUpdatesExtensions
    on Iterable<SpeechToTextResponseUpdate> {
  /// Combines the updates into a single [SpeechToTextResponse].
  SpeechToTextResponse toSpeechToTextResponse() {
    final response = SpeechToTextResponse();
    for (final update in this) {
      _processUpdate(update, response);
    }
    _coalesceTextContent(response.contents);
    return response;
  }
}

/// Combines a stream of [SpeechToTextResponseUpdate] instances into a
/// [SpeechToTextResponse].
extension SpeechToTextResponseUpdatesStreamExtensions
    on Stream<SpeechToTextResponseUpdate> {
  /// Drains the stream and combines the updates into a single
  /// [SpeechToTextResponse].
  Future<SpeechToTextResponse> toSpeechToTextResponse() async {
    final response = SpeechToTextResponse();
    await for (final update in this) {
      _processUpdate(update, response);
    }
    _coalesceTextContent(response.contents);
    return response;
  }
}

void _processUpdate(
  SpeechToTextResponseUpdate update,
  SpeechToTextResponse response,
) {
  if (update.responseId != null) {
    response.responseId = update.responseId;
  }
  if (update.modelId != null) {
    response.modelId = update.modelId;
  }
  if (response.startTime == null ||
      (update.startTime != null && update.startTime! < response.startTime!)) {
    response.startTime = update.startTime;
  }
  if (response.endTime == null ||
      (update.endTime != null && update.endTime! > response.endTime!)) {
    response.endTime = update.endTime;
  }
  for (final content in update.contents) {
    if (content is UsageContent) {
      (response.usage ??= UsageDetails()).add(content.details);
    } else {
      response.contents.add(content);
    }
  }
  if (update.usage != null) {
    (response.usage ??= UsageDetails()).add(update.usage!);
  }
  if (update.rawRepresentation != null) {
    response.rawRepresentation = update.rawRepresentation;
  }
  final props = update.additionalProperties;
  if (props != null) {
    (response.additionalProperties ??= {}).addAll(props);
  }
}

/// Merges runs of adjacent [TextContent] items into one, mirroring the
/// upstream `ChatResponseExtensions.CoalesceContent` pass.
void _coalesceTextContent(List<AIContent> contents) {
  for (var i = 0; i < contents.length - 1;) {
    if (contents[i] is TextContent && contents[i + 1] is TextContent) {
      final merged = StringBuffer((contents[i] as TextContent).text);
      var j = i + 1;
      while (j < contents.length && contents[j] is TextContent) {
        merged.write((contents[j] as TextContent).text);
        j++;
      }
      contents.replaceRange(i, j, [TextContent(merged.toString())]);
    }
    i++;
  }
}
