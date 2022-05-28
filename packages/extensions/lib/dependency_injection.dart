/// Dependency Injection
///
/// Provides support for registering and accessing dependencies according
/// to their service lifetime.
///
/// ```dart
/// import 'package:extensions/dependency_injection.dart';
///
/// void main(List<String>? args) {
///   var serviceCollection = ServiceCollection();
///   serviceCollection.addSingleton<MyService>(
///     implementationInstance: MyService(),
///   );
///
///   var services = serviceCollection.buildServiceProvider();
///   var myService = services.getRequiredService<MyService>();
/// }
/// ```
library dependency_injection;

export 'primitives.dart';
export 'src/dependency_injection/service_collection.dart';
export 'src/dependency_injection/service_collection_descriptor_extensions.dart';
export 'src/dependency_injection/service_collection_service_extensions.dart';
export 'src/dependency_injection/service_descriptor.dart';
export 'src/dependency_injection/service_lifetime.dart';
export 'src/dependency_injection/service_provider.dart';
export 'src/dependency_injection/service_provider_factory.dart';
export 'src/dependency_injection/service_provider_options.dart';
export 'src/dependency_injection/service_provider_service_extensions.dart';
export 'src/dependency_injection/service_scope_factory.dart';
