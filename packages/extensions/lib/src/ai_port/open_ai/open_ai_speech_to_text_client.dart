import '../abstractions/contents/text_content.dart';
import '../abstractions/contents/usage_content.dart';
import '../abstractions/speech_to_text/speech_to_text_client.dart';
import '../abstractions/speech_to_text/speech_to_text_client_metadata.dart';
import '../abstractions/speech_to_text/speech_to_text_options.dart';
import '../abstractions/speech_to_text/speech_to_text_response.dart';
import '../abstractions/speech_to_text/speech_to_text_response_update.dart';
import '../abstractions/speech_to_text/speech_to_text_response_update_kind.dart';
import '../abstractions/usage_details.dart';

/// Represents an [SpeechToTextClient] for an OpenAI [OpenAIClient] or
/// [AudioClient].
class OpenASpeechToTextClient implements SpeechToTextClient {
  /// Initializes a new instance of the [OpenAISpeechToTextClient] class for the
  /// specified [AudioClient].
  ///
  /// [audioClient] The underlying client.
  const OpenASpeechToTextClient(AudioClient audioClient) : _audioClient = Throw.ifNull(audioClient), _metadata = new("openai", audioClient.endpoint, _audioClient.model);

  /// Metadata about the client.
  final SpeechToTextClientMetadata _metadata;

  /// The underlying [AudioClient].
  final AudioClient _audioClient;

  @override
  Object? getService(Type serviceType, {Object? serviceKey, }) {
    _ = Throw.ifNull(serviceType);
    return serviceKey != null ? null :
            serviceType == typeof(SpeechToTextClientMetadata) ? _metadata :
            serviceType == typeof(AudioClient) ? _audioClient :
            serviceType.isInstanceOfType(this) ? this :
            null;
  }

  @override
  Future<SpeechToTextResponse> getText(
    Stream audioSpeechStream,
    {SpeechToTextOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    _ = Throw.ifNull(audioSpeechStream);
    var response = new();
    var filename = audioSpeechStream is FileStream fileStream ?
            Path.getFileName(fileStream.name) : // Use the file name if we can get one from the stream.
            Filename;
    if (isTranslationRequest(options)) {
      var translation = (await _audioClient.translateAudioAsync(audioSpeechStream, filename, toOpenAITranslationOptions(options), cancellationToken).configureAwait(false)).value;
      response.contents = [textContent(translation.text)];
      response.rawRepresentation = translation;
      var segmentCount = translation.segments.count;
      if (segmentCount > 0) {
        response.startTime = translation.segments[0].startTime;
        response.endTime = translation.segments[segmentCount - 1].endTime;
      }
    } else {
      var transcription = (await _audioClient.transcribeAudioAsync(audioSpeechStream, filename, toOpenAITranscriptionOptions(options), cancellationToken).configureAwait(false)).value;
      response.contents = [textContent(transcription.text)];
      response.rawRepresentation = transcription;
      var segmentCount = transcription.segments.count;
      if (segmentCount > 0) {
        response.startTime = transcription.segments[0].startTime;
        response.endTime = transcription.segments[segmentCount - 1].endTime;
      } else {
        var wordCount = transcription.words.count;
        if (wordCount > 0) {
          response.startTime = transcription.words[0].startTime;
          response.endTime = transcription.words[wordCount - 1].endTime;
        }
      }
      if (transcription.usage is AudioTranscriptionTokenUsage) {
        final tokenUsage = transcription.usage as AudioTranscriptionTokenUsage;
        response.usage = toUsageDetails(tokenUsage);
      }
    }
    return response;
  }

  @override
  Stream<SpeechToTextResponseUpdate> getStreamingText(
    Stream audioSpeechStream,
    {SpeechToTextOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    _ = Throw.ifNull(audioSpeechStream);
    var filename = audioSpeechStream is FileStream fileStream ?
            Path.getFileName(fileStream.name) : // Use the file name if we can get one from the stream.
            Filename;
    if (isTranslationRequest(options)) {
      for (final update in (await getTextAsync(audioSpeechStream, options, cancellationToken).configureAwait(false)).toSpeechToTextResponseUpdates()) {
        yield update;
      }
    } else {
      for (final update in _audioClient.transcribeAudioStreamingAsync(
                audioSpeechStream,
                filename,
                toOpenAITranscriptionOptions(options),
                cancellationToken).configureAwait(false)) {
        var result = new()
                {
                    ModelId = options?.modelId,
                    RawRepresentation = update,
                };
        switch (update) {
          case StreamingAudioTranscriptionTextDeltaUpdate deltaUpdate:
          result.kind = SpeechToTextResponseUpdateKind.textUpdated;
          result.contents = [textContent(deltaUpdate.delta)];
          case StreamingAudioTranscriptionTextSegmentUpdate segmentUpdate:
          result.kind = SpeechToTextResponseUpdateKind.textUpdated;
          result.startTime = segmentUpdate.startTime;
          result.endTime = segmentUpdate.endTime;
          case StreamingAudioTranscriptionTextDoneUpdate doneUpdate:
          result.kind = SpeechToTextResponseUpdateKind.sessionClose;
          if (doneUpdate.usage is { } usage) {
            result.contents = [usageContent(toUsageDetails(usage))];
          }
        }
        yield result;
      }
    }
  }

  void dispose() {

  }

  static bool isTranslationRequest(SpeechToTextOptions? options) {
    return options != null &&
        options.textLanguage != null &&
        (options.speechLanguage == null || options.speechLanguage != options.textLanguage);
  }

  /// Converts an extensions options instance to an OpenAI transcription options
  /// instance.
  AudioTranscriptionOptions toOpenAITranscriptionOptions(SpeechToTextOptions? options) {
    var result = options?.rawRepresentationFactory?.invoke(this) as AudioTranscriptionOptions ?? new();
    result.language ??= options?.speechLanguage;
    return result;
  }

  /// Converts an extensions options instance to an OpenAI translation options
  /// instance.
  AudioTranslationOptions toOpenAITranslationOptions(SpeechToTextOptions? options) {
    var result = options?.rawRepresentationFactory?.invoke(this) as AudioTranslationOptions ?? new();
    return result;
  }

  /// Maps [AudioTranscriptionTokenUsage] to [UsageDetails].
  static UsageDetails toUsageDetails(AudioTranscriptionTokenUsage tokenUsage) {
    var details = usageDetails();
    if (tokenUsage.inputTokenDetails is { } inputDetails) {
      details.inputAudioTokenCount = inputDetails.audioTokenCount;
      details.inputTextTokenCount = inputDetails.textTokenCount;
    }
    return details;
  }
}
