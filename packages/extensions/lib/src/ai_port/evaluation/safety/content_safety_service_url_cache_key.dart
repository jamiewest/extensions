import 'content_safety_service_configuration.dart';

class ContentSafetyService {
  ContentSafetyService();
}

class UrlCacheKey {
  const UrlCacheKey(
    ContentSafetyServiceConfiguration configuration,
    String annotationTask,
  ) : configuration = configuration,
      annotationFuture = annotationTask;

  final ContentSafetyServiceConfiguration configuration = configuration;

  final String annotationFuture = annotationTask;

  @override
  bool equals({UrlCacheKey? other}) {
    // TODO(ai): implement dispatch
    throw UnimplementedError();
  }

  @override
  int getHashCode() {
    return HashCode.combine(
      configuration.subscriptionId,
      configuration.resourceGroupName,
      configuration.projectName,
      configuration.endpoint,
      annotationFuture,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UrlCacheKey &&
        configuration == other.configuration &&
        annotationFuture == other.annotationFuture;
  }

  @override
  int get hashCode {
    return Object.hash(configuration, annotationFuture);
  }
}
