import '../abstractions/contents/data_content.dart';
import '../abstractions/contents/usage_content.dart';
import '../abstractions/text_to_speech/text_to_speech_client.dart';
import '../abstractions/text_to_speech/text_to_speech_client_metadata.dart';
import '../abstractions/text_to_speech/text_to_speech_options.dart';
import '../abstractions/text_to_speech/text_to_speech_response.dart';
import '../abstractions/text_to_speech/text_to_speech_response_update.dart';

/// Represents an [TextToSpeechClient] for an OpenAI [OpenAIClient] or
/// [AudioClient].
class OpenATextToSpeechClient implements TextToSpeechClient {
  /// Initializes a new instance of the [OpenAITextToSpeechClient] class for the
  /// specified [AudioClient].
  ///
  /// [audioClient] The underlying client.
  const OpenATextToSpeechClient(AudioClient audioClient) : _audioClient = Throw.ifNull(audioClient), _metadata = new("openai", audioClient.endpoint, _audioClient.model);

  /// Metadata about the client.
  final TextToSpeechClientMetadata _metadata;

  /// The underlying [AudioClient].
  final AudioClient _audioClient;

  @override
  Object? getService(Type serviceType, {Object? serviceKey, }) {
    _ = Throw.ifNull(serviceType);
    return serviceKey != null ? null :
            serviceType == typeof(TextToSpeechClientMetadata) ? _metadata :
            serviceType == typeof(AudioClient) ? _audioClient :
            serviceType.isInstanceOfType(this) ? this :
            null;
  }

  @override
  Future<TextToSpeechResponse> getAudio(
    String text,
    {TextToSpeechOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    _ = Throw.ifNull(text);
    var openAIOptions = toOpenAISpeechOptions(options);
    var result = await _audioClient.generateSpeechAsync(
            text,
            generatedSpeechVoice(options?.voiceId ?? DefaultVoice),
            openAIOptions,
            cancellationToken).configureAwait(false);
    var mediaType = getMediaType(openAIOptions.responseFormat);
    return textToSpeechResponse([dataContent(result.value.toMemory(), mediaType)])
        {
            ModelId = options?.modelId ?? _metadata.defaultModelId,
            RawRepresentation = result,
        };
  }

  @override
  Stream<TextToSpeechResponseUpdate> getStreamingAudio(
    String text,
    {TextToSpeechOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    _ = Throw.ifNull(text);
    var openAIOptions = toOpenAISpeechOptions(options);
    var mediaType = getMediaType(openAIOptions.responseFormat);
    var streamingResult = null;
    try {
      streamingResult = _audioClient.generateSpeechStreamingAsync(
                text,
                generatedSpeechVoice(options?.voiceId ?? DefaultVoice),
                openAIOptions,
                cancellationToken);
    } catch (e, s) {
      if (e is NotSupportedException) {
        final  = e as NotSupportedException;
        {}
      } else {
        rethrow;
      }
    }
    if (streamingResult == null) {
      for (final update in (await getAudioAsync(text, options, cancellationToken).configureAwait(false)).toTextToSpeechResponseUpdates()) {
        yield update;
      }
      return;
    }
    for (final update in streamingResult.configureAwait(false)) {
      switch (update) {
        case StreamingSpeechAudioDeltaUpdate deltaUpdate:
        yield textToSpeechResponseUpdate();
        case StreamingSpeechAudioDoneUpdate doneUpdate:
        var sessionClose = textToSpeechResponseUpdate();
        if (doneUpdate.usage is { } usage) {
          sessionClose.contents = [usageContent(new())];
        }
        yield sessionClose;
      }
    }
  }

  void dispose() {

  }

  /// Converts an extensions options instance to an OpenAI speech generation
  /// options instance.
  SpeechGenerationOptions toOpenAISpeechOptions(TextToSpeechOptions? options) {
    var result = options?.rawRepresentationFactory?.invoke(this) as SpeechGenerationOptions ?? new();
    if (options?.speed is float) {
      final speed = options?.speed as float;
      result.speedRatio ??= speed;
    }
    if (options?.audioFormat is string) {
      final audioFormat = options?.audioFormat as string;
      result.responseFormat ??= toGeneratedSpeechFormat(audioFormat);
    }
    return result;
  }

  /// Maps a format string to a [GeneratedSpeechFormat].
  static GeneratedSpeechFormat? toGeneratedSpeechFormat(String format) {
    return format.toUpperInvariant() switch
    {
        "MP3" or "AUDIO/MPEG" => GeneratedSpeechFormat.mp3,
        "OPUS" or "AUDIO/OPUS" => GeneratedSpeechFormat.opus,
        "AAC" or "AUDIO/AAC" => GeneratedSpeechFormat.aac,
        "FLAC" or "AUDIO/FLAC" => GeneratedSpeechFormat.flac,
        "WAV" or "AUDIO/WAV" => GeneratedSpeechFormat.wav,
        "PCM" or "AUDIO/L16" => GeneratedSpeechFormat.pcm,
        (_) => generatedSpeechFormat(format),
    };
  }

  /// Gets the media type for the specified response format.
  static String getMediaType(GeneratedSpeechFormat? format) {
    return format?.toString() switch
    {
        "mp3" => "audio/mpeg",
        "opus" => "audio/opus",
        "aac" => "audio/aac",
        "flac" => "audio/flac",
        "wav" => "audio/wav",
        "pcm" => "audio/l16",
        (null) => "audio/mpeg", // OpenAI default is mp3
        (_) => "application/octet-stream",
    };
  }
}
