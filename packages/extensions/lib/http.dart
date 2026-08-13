/// Provides typed HTTP client factory with lifetime management and
/// request/response logging.
///
/// This library implements HTTP client abstractions inspired by
/// Microsoft.Extensions.Http, offering centralized configuration,
/// automatic logging, and proper resource management for HTTP clients.
///
/// ## HTTP Client Factory
///
/// Register the factory and its logging filter on a service collection:
///
/// {@example /example/example_http_client_logging.dart#http_client_factory_setup}
///
/// Resolve the factory to create clients:
///
/// {@example /example/example_http_client_logging.dart#resolve_http_client}
///
/// ## Named Clients
///
/// Each name carries its own handler pipeline, header redaction, and
/// handler lifetime:
///
/// {@example /example/example_http_client_logging.dart#named_client_redaction}
///
/// ## Request Logging
///
/// Automatically log HTTP requests and responses:
///
/// ```dart
/// services
///   ..addLogging((builder) => builder.addSimpleConsole())
///   ..addHttpClient()
///   ..addHttpClientLogging();  // Enables request/response logging
/// ```
///
/// ## Message Handlers
///
/// Add custom message handlers for cross-cutting concerns:
///
/// ```dart
/// services.addHttpClient('API')
///   .addHttpMessageHandler((sp) => AuthenticationHandler())
///   .addHttpMessageHandler((sp) => RetryHandler());
/// ```
library;

export 'src/http/delegating_handler.dart';
export 'src/http/http_client_builder.dart';
export 'src/http/http_client_factory.dart';
export 'src/http/http_client_factory_options.dart';
export 'src/http/http_client_factory_service_collection_extensions.dart';
export 'src/http/http_message_handler.dart';
export 'src/http/http_message_handler_builder.dart';
export 'src/http/http_message_handler_builder_filter.dart';
export 'src/http/http_message_handler_factory.dart';
export 'src/http/lifetime_tracking_http_message_handler.dart';
export 'src/http/logging/http_client_async_logger.dart';
export 'src/http/logging/http_client_logger.dart';
export 'src/http/logging/http_client_logger_handler.dart';
export 'src/http/logging/logging_http_message_handler.dart';
export 'src/http/logging/logging_http_message_handler_builder_filter.dart';
export 'src/http/logging/logging_scope_http_message_handler.dart';
