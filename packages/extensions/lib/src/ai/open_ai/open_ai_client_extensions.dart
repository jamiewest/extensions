import 'package:extensions/annotations.dart';

import '../../dependency_injection/service_collection.dart';
import '../../dependency_injection/service_descriptor.dart';
import '../chat_completion/chat_client.dart';
import '../chat_completion/chat_client_builder.dart';
import '../embeddings/embedding_generator.dart';
import '../embeddings/embedding_generator_builder.dart';
import '../image_generation/image_generator.dart';
import '../image_generation/image_generator_builder.dart';
import '../speech_to_text/speech_to_text_client.dart';
import '../speech_to_text/speech_to_text_client_builder.dart';
import '../text_to_speech/text_to_speech_client.dart';
import '../text_to_speech/text_to_speech_client_builder.dart';
import 'open_ai_chat_client.dart';
import 'open_ai_client_options.dart';
import 'open_ai_embedding_generator.dart';
import 'open_ai_image_generator.dart';
import 'open_ai_speech_to_text_client.dart';
import 'open_ai_text_to_speech_client.dart';

/// The default OpenAI API endpoint.
///
/// Corresponds to `DefaultOpenAIEndpoint` in `OpenAIClientExtensions.cs`.
final Uri defaultOpenAIEndpoint = Uri.parse('https://api.openai.com/v1');

/// Provides extension methods for building [OpenAIChatClient] pipelines.
@Source(
  name: 'OpenAIClientExtensions.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.OpenAI/',
)
extension OpenAIChatClientExtensions on OpenAIChatClient {
  /// Creates a [ChatClientBuilder] wrapping this client.
  ChatClientBuilder asBuilder() => ChatClientBuilder(this);
}

/// Provides extension methods for registering OpenAI clients in a
/// [ServiceCollection].
extension OpenAIServiceCollectionExtensions on ServiceCollection {
  /// Registers an [OpenAIChatClient] (optionally wrapped by [configure]) and
  /// its [ChatClient] abstraction as singletons.
  ServiceCollection addOpenAIChatClient(
    String modelId,
    String apiKey, {
    OpenAIClientOptions? options,
    void Function(ChatClientBuilder)? configure,
  }) {
    final inner = OpenAIChatClient(modelId, apiKey, options: options);
    final builder = inner.asBuilder();
    configure?.call(builder);
    add(ServiceDescriptor.singleton<ChatClient>((_) => builder.build()));
    add(ServiceDescriptor.singleton<OpenAIChatClient>((_) => inner));
    return this;
  }

  /// Registers an [OpenAIEmbeddingGenerator] (optionally wrapped by
  /// [configure]) and its [EmbeddingGenerator] abstraction as singletons.
  ServiceCollection addOpenAIEmbeddingGenerator(
    String modelId,
    String apiKey, {
    int? defaultModelDimensions,
    OpenAIClientOptions? options,
    void Function(EmbeddingGeneratorBuilder)? configure,
  }) {
    final inner = OpenAIEmbeddingGenerator(
      modelId,
      apiKey,
      defaultModelDimensions: defaultModelDimensions,
      options: options,
    );
    final builder = EmbeddingGeneratorBuilder(inner);
    configure?.call(builder);
    add(ServiceDescriptor.singleton<EmbeddingGenerator>(
      (_) => builder.build(),
    ));
    add(ServiceDescriptor.singleton<OpenAIEmbeddingGenerator>((_) => inner));
    return this;
  }

  /// Registers an [OpenAIImageGenerator] (optionally wrapped by [configure])
  /// and its [ImageGenerator] abstraction as singletons.
  ServiceCollection addOpenAIImageGenerator(
    String modelId,
    String apiKey, {
    OpenAIClientOptions? options,
    void Function(ImageGeneratorBuilder)? configure,
  }) {
    final inner = OpenAIImageGenerator(modelId, apiKey, options: options);
    final builder = ImageGeneratorBuilder(inner);
    configure?.call(builder);
    add(ServiceDescriptor.singleton<ImageGenerator>((_) => builder.build()));
    add(ServiceDescriptor.singleton<OpenAIImageGenerator>((_) => inner));
    return this;
  }

  /// Registers an [OpenAISpeechToTextClient] and its [SpeechToTextClient]
  /// abstraction as singletons.
  ServiceCollection addOpenAISpeechToTextClient(
    String modelId,
    String apiKey, {
    OpenAIClientOptions? options,
    void Function(SpeechToTextClientBuilder)? configure,
  }) {
    final inner = OpenAISpeechToTextClient(modelId, apiKey, options: options);
    final builder = SpeechToTextClientBuilder(inner);
    configure?.call(builder);
    add(ServiceDescriptor.singleton<SpeechToTextClient>(
      (_) => builder.build(),
    ));
    add(ServiceDescriptor.singleton<OpenAISpeechToTextClient>((_) => inner));
    return this;
  }

  /// Registers an [OpenAITextToSpeechClient] and its [TextToSpeechClient]
  /// abstraction as singletons.
  ServiceCollection addOpenAITextToSpeechClient(
    String modelId,
    String apiKey, {
    OpenAIClientOptions? options,
    void Function(TextToSpeechClientBuilder)? configure,
  }) {
    final inner = OpenAITextToSpeechClient(modelId, apiKey, options: options);
    final builder = TextToSpeechClientBuilder(inner);
    configure?.call(builder);
    add(ServiceDescriptor.singleton<TextToSpeechClient>(
      (_) => builder.build(),
    ));
    add(ServiceDescriptor.singleton<OpenAITextToSpeechClient>((_) => inner));
    return this;
  }
}
