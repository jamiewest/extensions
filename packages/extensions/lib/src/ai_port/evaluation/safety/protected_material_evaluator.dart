import '../../abstractions/chat_completion/chat_message.dart';
import '../boolean_metric.dart';
import '../chat_configuration.dart';
import '../evaluation_context.dart';
import '../evaluation_result.dart';
import '../evaluator.dart';
import 'content_safety_evaluator.dart';
import 'content_safety_service_payload_format.dart';

/// An [Evaluator] that utilizes the Azure AI Foundry Evaluation service to
/// evaluate responses produced by an AI model for presence of protected
/// material.
///
/// Remarks: Protected material includes any text that is under copyright,
/// including song lyrics, recipes, and articles. Note that
/// [ProtectedMaterialEvaluator] can also detect protected material present
/// within image content in the evaluated responses. Supported file formats
/// include JPG/JPEG, PNG and GIF and the evaluation can detect copyrighted
/// artwork, fictional characters, and logos and branding that are registered
/// trademarks. Other modalities such as audio and video are currently not
/// supported. [ProtectedMaterialEvaluator] returns a [BooleanMetric] with a
/// value of `true` indicating the presence of protected material in the
/// response, and a value of `false` indicating the absence of protected
/// material.
class ProtectedMaterialEvaluator extends ContentSafetyEvaluator {
  /// An [Evaluator] that utilizes the Azure AI Foundry Evaluation service to
  /// evaluate responses produced by an AI model for presence of protected
  /// material.
  ///
  /// Remarks: Protected material includes any text that is under copyright,
  /// including song lyrics, recipes, and articles. Note that
  /// [ProtectedMaterialEvaluator] can also detect protected material present
  /// within image content in the evaluated responses. Supported file formats
  /// include JPG/JPEG, PNG and GIF and the evaluation can detect copyrighted
  /// artwork, fictional characters, and logos and branding that are registered
  /// trademarks. Other modalities such as audio and video are currently not
  /// supported. [ProtectedMaterialEvaluator] returns a [BooleanMetric] with a
  /// value of `true` indicating the presence of protected material in the
  /// response, and a value of `false` indicating the absence of protected
  /// material.
  const ProtectedMaterialEvaluator();

  /// Gets the [Name] of the [BooleanMetric] returned by
  /// [ProtectedMaterialEvaluator] for indicating presence of protected material
  /// in responses.
  static String get protectedMaterialMetricName {
    return "Protected Material";
  }

  /// Gets the [Name] of the [BooleanMetric] returned by
  /// [ProtectedMaterialEvaluator] for indicating presence of protected material
  /// in artwork in images.
  static String get protectedArtworkMetricName {
    return "Protected Artwork";
  }

  /// Gets the [Name] of the [BooleanMetric] returned by
  /// [ProtectedMaterialEvaluator] for indicating presence of protected
  /// fictional characters in images.
  static String get protectedFictionalCharactersMetricName {
    return "Protected Fictional Characters";
  }

  /// Gets the [Name] of the [BooleanMetric] returned by
  /// [ProtectedMaterialEvaluator] for indicating presence of protected logos
  /// and brands in images.
  static String get protectedLogosAndBrandsMetricName {
    return "Protected Logos And Brands";
  }

  @override
  Future<EvaluationResult> evaluate(
    Iterable<ChatMessage> messages,
    ChatResponse modelResponse, {
    ChatConfiguration? chatConfiguration,
    Iterable<EvaluationContext>? additionalContext,
    CancellationToken? cancellationToken,
  }) async {
    _ = Throw.ifNull(chatConfiguration);
    _ = Throw.ifNull(modelResponse);
    var chatClient = chatConfiguration.chatClient;
    var result = await evaluateContentSafetyAsync(
      chatClient,
      messages,
      modelResponse,
      contentSafetyServicePayloadFormat: ContentSafetyServicePayloadFormat
          .humanSystem
          .toString(),
      includeMetricNamesInContentSafetyServicePayload: false,
      cancellationToken: cancellationToken,
    ).configureAwait(false);
    if (messages.containsImageWithSupportedFormat() ||
        modelResponse.containsImageWithSupportedFormat()) {
      var imageResult = await evaluateContentSafetyAsync(
        chatClient,
        messages,
        modelResponse,
        contentSafetyServicePayloadFormat: ContentSafetyServicePayloadFormat
            .conversation
            .toString(),
        includeMetricNamesInContentSafetyServicePayload: false,
        cancellationToken: cancellationToken,
      ).configureAwait(false);
      for (final imageMetric in imageResult.metrics.values) {
        result.metrics.add(imageMetric.name, imageMetric);
      }
    }
    return result;
  }
}
