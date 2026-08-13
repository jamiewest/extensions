import '../../dependency_injection/service_collection.dart';
import '../../dependency_injection/service_descriptor.dart';
import '../../dependency_injection/service_lifetime.dart';
import 'speech_to_text_client.dart';
import 'speech_to_text_client_builder.dart';

/// Provides extension methods for registering [SpeechToTextClient] with a
/// [ServiceCollection].
///
/// This is an experimental feature.
extension SpeechToTextClientBuilderServiceCollectionExtensions
    on ServiceCollection {
  /// Registers a [SpeechToTextClient] in the service collection and returns
  /// a [SpeechToTextClientBuilder] for adding middleware to the pipeline.
  SpeechToTextClientBuilder addSpeechToTextClient(
    InnerSpeechToTextClientFactory innerClientFactory, [
    ServiceLifetime lifetime = ServiceLifetime.singleton,
  ]) {
    final builder = SpeechToTextClientBuilder.fromFactory(innerClientFactory);
    add(switch (lifetime) {
      ServiceLifetime.singleton =>
        ServiceDescriptor.singleton<SpeechToTextClient>(
          (sp) => builder.build(sp),
        ),
      ServiceLifetime.scoped => ServiceDescriptor.scoped<SpeechToTextClient>(
        (sp) => builder.build(sp),
      ),
      ServiceLifetime.transient =>
        ServiceDescriptor.transient<SpeechToTextClient>(
          (sp) => builder.build(sp),
        ),
    });
    return builder;
  }
}
