import '../abstractions/chat_completion/chat_client.dart';
import '../abstractions/files/hosted_file_client.dart';
import '../abstractions/image/image_generator.dart';
import '../abstractions/speech_to_text/speech_to_text_client.dart';
import '../abstractions/text_to_speech/text_to_speech_client.dart';
import 'open_ai_chat_client.dart';
import 'open_ai_embedding_generator.dart';
import 'open_ai_hosted_file_client.dart';
import 'open_ai_image_generator.dart';
import 'open_ai_speech_to_text_client.dart';
import 'open_ai_text_to_speech_client.dart';

/// Provides extension methods for working with [OpenAIClient]s.
extension OpenAClientExtensions on ChatClient {
  /// Gets an [ChatClient] for use with this [ChatClient].
///
/// Returns: An [ChatClient] that can be used to converse via the
/// [ChatClient].
///
/// [chatClient] The client.
ChatClient asIChatClient({ResponsesClient? responseClient, String? defaultModelId, AssistantClient? assistantClient, String? assistantId, String? threadId, Assistant? assistant, }) {
return openAChatClient(chatClient);
 }
/// Gets an [SpeechToTextClient] for use with this [AudioClient].
///
/// Returns: An [SpeechToTextClient] that can be used to transcribe audio via
/// the [AudioClient].
///
/// [audioClient] The client.
SpeechToTextClient asISpeechToTextClient() {
return openASpeechToTextClient(audioClient);
 }
/// Gets an [TextToSpeechClient] for use with this [AudioClient].
///
/// Returns: An [TextToSpeechClient] that can be used to generate speech via
/// the [AudioClient].
///
/// [audioClient] The client.
TextToSpeechClient asITextToSpeechClient() {
return openATextToSpeechClient(audioClient);
 }
/// Gets an [ImageGenerator] for use with this [ImageClient].
///
/// Returns: An [ImageGenerator] that can be used to generate images via the
/// [ImageClient].
///
/// [imageClient] The client.
ImageGenerator asIImageGenerator() {
return openAImageGenerator(imageClient);
 }
/// Gets an [EmbeddingGenerator] for use with this [EmbeddingClient].
///
/// Returns: An [EmbeddingGenerator] that can be used to generate embeddings
/// via the [EmbeddingClient].
///
/// [embeddingClient] The client.
///
/// [defaultModelDimensions] The number of dimensions to generate in each
/// embedding.
EmbeddingGenerator<String, Embedding<double>> asIEmbeddingGenerator({int? defaultModelDimensions}) {
return openAEmbeddingGenerator(embeddingClient, defaultModelDimensions);
 }
/// Gets an [HostedFileClient] for use with this [OpenAIClient].
///
/// Remarks: The returned [HostedFileClient] supports both the standard Files
/// API and container files (used for code interpreter outputs). To download a
/// container file, specify the container ID in the [Scope] property.
///
/// Returns: An [HostedFileClient] that can be used to manage files via the
/// [OpenAIClient].
///
/// [openAIClient] The client.
HostedFileClient asIHostedFileClient({OpenAFileClient? fileClient, ContainerClient? containerClient, String? defaultScope, }) {
return openAHostedFileClient(openAIClient);
 }
/// Gets the typed property of the specified name from the tool's
/// [AdditionalProperties].
T? getProperty<T>(String name) {
return tool.additionalProperties?.tryGetValue(
  name,
  out object? value,
) is true && value is T tValue ? tValue : default;
 }
 }
/// Used to create the JSON payload for an OpenAI tool description.
class ToolJson {
  ToolJson();

  String type = "object";

  Set<String> required = [];

  Map<String, JsonElement> properties = [];

  bool additionalProperties;

  Map<String, JsonElement>? extensionData;

}
