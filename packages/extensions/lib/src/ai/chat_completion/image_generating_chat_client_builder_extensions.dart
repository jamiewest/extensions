import '../../dependency_injection/service_provider_service_extensions.dart';
import '../image_generation/image_generator.dart';
import 'chat_client_builder.dart';
import 'image_generating_chat_client.dart';

/// Provides extensions for adding [ImageGeneratingChatClient] to a
/// [ChatClientBuilder] pipeline.
///
/// This is an experimental feature.
extension ImageGeneratingChatClientBuilderExtensions on ChatClientBuilder {
  /// Adds an [ImageGeneratingChatClient] that fulfills image generation
  /// requests using [imageGenerator].
  ///
  /// When [imageGenerator] is omitted, it is resolved from the service
  /// provider at build time.
  ChatClientBuilder useImageGeneration({ImageGenerator? imageGenerator}) =>
      useWithServices((inner, services) => ImageGeneratingChatClient(
            inner,
            imageGenerator:
                imageGenerator ?? services.getRequiredService<ImageGenerator>(),
          ));
}
