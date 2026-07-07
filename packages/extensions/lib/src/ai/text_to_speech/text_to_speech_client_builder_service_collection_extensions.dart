import '../../dependency_injection/service_collection.dart';
import '../../dependency_injection/service_descriptor.dart';
import '../../dependency_injection/service_lifetime.dart';
import 'text_to_speech_client.dart';
import 'text_to_speech_client_builder.dart';

/// Provides extension methods for registering [TextToSpeechClient] with a
/// [ServiceCollection].
///
/// This is an experimental feature.
extension TextToSpeechClientBuilderServiceCollectionExtensions
    on ServiceCollection {
  /// Registers a [TextToSpeechClient] in the service collection and returns
  /// a [TextToSpeechClientBuilder] for adding middleware to the pipeline.
  TextToSpeechClientBuilder addTextToSpeechClient(
    InnerTextToSpeechClientFactory innerClientFactory, [
    ServiceLifetime lifetime = ServiceLifetime.singleton,
  ]) {
    final builder = TextToSpeechClientBuilder.fromFactory(innerClientFactory);
    add(switch (lifetime) {
      ServiceLifetime.singleton =>
        ServiceDescriptor.singleton<TextToSpeechClient>(
          (sp) => builder.build(sp),
        ),
      ServiceLifetime.scoped => ServiceDescriptor.scoped<TextToSpeechClient>(
          (sp) => builder.build(sp),
        ),
      ServiceLifetime.transient =>
        ServiceDescriptor.transient<TextToSpeechClient>(
          (sp) => builder.build(sp),
        ),
    });
    return builder;
  }
}
