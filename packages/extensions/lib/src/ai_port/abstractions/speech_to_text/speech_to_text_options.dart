import '../../../../../../lib/func_typedefs.dart';
import 'speech_to_text_client.dart';

/// Represents the options for an speech to text request.
class SpeechToTextOptions {
  /// Initializes a new instance of the [SpeechToTextOptions] class, performing
  /// a shallow copy of all properties from `other`.
  SpeechToTextOptions(SpeechToTextOptions? other) : additionalProperties = other.additionalProperties?.clone(), modelId = other.modelId, rawRepresentationFactory = other.rawRepresentationFactory, speechLanguage = other.speechLanguage, speechSampleRate = other.speechSampleRate, textLanguage = other.textLanguage {
    if (other == null) {
      return;
    }
  }

  /// Gets or sets any additional properties associated with the options.
  AdditionalPropertiesDictionary? additionalProperties;

  /// Gets or sets the model ID for the speech to text.
  String? modelId;

  /// Gets or sets the language of source speech.
  String? speechLanguage;

  /// Gets or sets the sample rate of the speech input audio.
  int? speechSampleRate;

  /// Gets or sets the language for the target generated text.
  String? textLanguage;

  /// Gets or sets a callback responsible for creating the raw representation of
  /// the embedding generation options from an underlying implementation.
  ///
  /// Remarks: The underlying [SpeechToTextClient] implementation may have its
  /// own representation of options. When [CancellationToken)] or
  /// [CancellationToken)] is invoked with an [SpeechToTextOptions], that
  /// implementation may convert the provided options into its own
  /// representation in order to use it while performing the operation. For
  /// situations where a consumer knows which concrete [SpeechToTextClient] is
  /// being used and how it represents options, a new instance of that
  /// implementation-specific options type may be returned by this callback, for
  /// the [SpeechToTextClient] implementation to use instead of creating a new
  /// instance. Such implementations may mutate the supplied options instance
  /// further based on other settings supplied on this [SpeechToTextOptions]
  /// instance or from other inputs, therefore, it is strongly recommended to
  /// not return shared instances and instead make the callback return a new
  /// instance on each call. This is typically used to set an
  /// implementation-specific setting that isn't otherwise exposed from the
  /// strongly typed properties on [SpeechToTextOptions].
  Func<SpeechToTextClient, Object?>? rawRepresentationFactory;

  /// Produces a clone of the current [SpeechToTextOptions] instance.
  ///
  /// Returns: A clone of the current [SpeechToTextOptions] instance.
  SpeechToTextOptions clone() {
    return new(this);
  }
}
