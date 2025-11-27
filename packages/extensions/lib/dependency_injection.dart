/// Provides a dependency injection container for managing services and
/// their lifetimes.
///
/// This library implements the dependency injection pattern inspired by
/// Microsoft.Extensions.DependencyInjection, enabling loose coupling and
/// testability through constructor injection.
///
/// ## Service Lifetimes
///
/// Services can be registered with three different lifetimes:
///
/// - **Transient**: A new instance is created each time it's requested
/// - **Scoped**: One instance per scope (typically per request)
/// - **Singleton**: A single instance shared across the application
///
/// ## Basic Usage
///
/// Register and resolve services:
///
/// ```dart
/// final services = ServiceCollection()
///   ..addSingleton<ILogger, ConsoleLogger>()
///   ..addScoped<IDatabase, SqlDatabase>()
///   ..addTransient<IEmailService, SmtpEmailService>();
///
/// final provider = services.buildServiceProvider();
/// final logger = provider.getRequiredService<ILogger>();
/// ```
///
/// ## Keyed Services
///
/// Register multiple implementations with different keys:
///
/// ```dart
/// services
///   ..addKeyedSingleton<ICache, RedisCache>('redis')
///   ..addKeyedSingleton<ICache, MemoryCache>('memory');
///
/// final redisCache = provider.getRequiredKeyedService<ICache>('redis');
/// ```
///
/// ## Service Scopes
///
/// Create scoped services for request-scoped lifetimes:
///
/// ```dart
/// await using((scope) async {
///   final db = scope.serviceProvider.getRequiredService<IDatabase>();
///   await db.saveChanges();
/// }, provider.createScope());
/// ```
library;

export 'src/dependency_injection/async_service_scope.dart';
export 'src/dependency_injection/default_service_provider_factory.dart';
export 'src/dependency_injection/service_collection.dart';
export 'src/dependency_injection/service_collection_container_builder_extensions.dart';
export 'src/dependency_injection/service_collection_descriptor_extensions.dart';
export 'src/dependency_injection/service_collection_service_extensions.dart';
export 'src/dependency_injection/service_descriptor.dart';
export 'src/dependency_injection/service_lifetime.dart';
export 'src/dependency_injection/service_provider.dart';
export 'src/dependency_injection/service_provider_factory.dart';
export 'src/dependency_injection/service_provider_is_keyed_service.dart';
export 'src/dependency_injection/service_provider_is_service.dart';
export 'src/dependency_injection/service_provider_keyed_service_extensions.dart';
export 'src/dependency_injection/service_provider_options.dart';
export 'src/dependency_injection/service_provider_service_extensions.dart';
export 'src/dependency_injection/service_scope.dart';
export 'src/dependency_injection/service_scope_factory.dart';
export 'src/dependency_injection/support_required_service.dart';
