/// Dependency Injection
///
/// Provides support for registering and accessing dependencies according
/// to their service lifetime.
///
/// ```dart
/// var serviceCollection = ServiceCollection();
/// serviceCollection.addSingleton<MyService>();
///
/// var services = serviceCollection.buildServiceProvider();
/// var myService = services.getRequiredService<MyService>();
/// ```
library dependency_injection;

export 'src/dependency_injection/service_collection.dart';
export 'src/dependency_injection/service_collection_descriptor_extensions.dart';
export 'src/dependency_injection/service_collection_service_extensions.dart';
export 'src/dependency_injection/service_descriptor.dart';
export 'src/dependency_injection/service_lifetime.dart';
export 'src/dependency_injection/service_provider.dart';
export 'src/dependency_injection/service_provider_factory.dart';
export 'src/dependency_injection/service_provider_options.dart';
export 'src/dependency_injection/service_provider_service_extensions.dart';

export 'src/shared/async_disposable.dart';
export 'src/shared/cancellation_token.dart';
export 'src/shared/disposable.dart';
