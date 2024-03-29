/// Dependency Injection
///
/// Provides support for registering and accessing dependencies according
/// to their service lifetime.
///
/// To use, import `package:extensions/dependency_injection.dart`.
/// {@category DependencyInjection}
library extensions.dependency_injection;

export 'primitives.dart';
export 'src/dependency_injection/service_collection.dart';
export 'src/dependency_injection/service_collection_container_builder_extensions.dart';
export 'src/dependency_injection/service_collection_descriptor_extensions.dart';
export 'src/dependency_injection/service_collection_service_extensions.dart';
export 'src/dependency_injection/service_descriptor.dart';
export 'src/dependency_injection/service_lifetime.dart';
export 'src/dependency_injection/service_provider.dart';
export 'src/dependency_injection/service_provider_factory.dart';
export 'src/dependency_injection/service_provider_options.dart';
export 'src/dependency_injection/service_provider_service_extensions.dart';
export 'src/dependency_injection/service_scope_factory.dart';
