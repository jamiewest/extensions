import 'package:http/http.dart' as http;

import '../dependency_injection/service_collection.dart';
import '../dependency_injection/service_collection_descriptor_extensions.dart';
import '../dependency_injection/service_descriptor.dart';
import '../dependency_injection/service_provider.dart';
import '../dependency_injection/service_provider_service_extensions.dart';
import '../options/options_service_collection_extensions.dart';
import 'delegating_handler.dart';
import 'http_client_factory.dart';
import 'http_client_factory_options.dart';
import 'http_message_handler.dart';

/// Fluent builder used to configure named HTTP clients.
class HttpClientBuilder {
  HttpClientBuilder(this.services, this.name);

  /// The service collection the client is registered with.
  final ServiceCollection services;

  /// The logical name of the client.
  final String name;

  /// Adds an action to configure the outgoing client instance.
  HttpClientBuilder configureHttpClient(
    void Function(http.BaseClient client, ServiceProvider services) configure,
  ) {
    services.configure<HttpClientFactoryOptions>(
      HttpClientFactoryOptions.new,
      (options) => options.httpClientActions.add(configure),
      name: name,
    );
    return this;
  }

  /// Sets the primary handler for the client.
  HttpClientBuilder configurePrimaryHttpMessageHandler(
    HttpMessageHandler Function(ServiceProvider services) factory,
  ) =>
      configureHttpMessageHandlerBuilder(
        (builder, sp) => builder.primaryHandler = factory(sp),
      );

  /// Adds a delegate to mutate the handler pipeline.
  HttpClientBuilder configureHttpMessageHandlerBuilder(
    HttpMessageHandlerBuilderAction configure,
  ) {
    services.configure<HttpClientFactoryOptions>(
      HttpClientFactoryOptions.new,
      (options) => options.httpMessageHandlerBuilderActions.add(configure),
      name: name,
    );
    return this;
  }

  /// Adds a delegating handler to the pipeline.
  HttpClientBuilder addHttpMessageHandler(
    HttpMessageHandler Function(ServiceProvider services) handlerFactory,
  ) =>
      configureHttpMessageHandlerBuilder(
        (builder, sp) => builder.additionalHandlers.add(
          handlerFactory(sp) as DelegatingHandler,
        ),
      );

  /// Registers a typed client that depends on this named client.
  HttpClientBuilder addTypedClient<TClient extends Object>(
    TClient Function(http.BaseClient client, ServiceProvider services) factory,
  ) {
    services.tryAdd(
      ServiceDescriptor.transient<TClient>(
        (sp) {
          var client =
              sp.getRequiredService<HttpClientFactory>().createClient(name);
          return factory(client, sp);
        },
      ),
    );
    return this;
  }

  /// Configures the header redaction for this HTTP client.
  ///
  /// Headers matching the provided predicate will have their values
  /// redacted in logs.
  ///
  /// Example:
  /// ```dart
  /// services.addHttpClient('MyClient')
  ///   .redactLoggedHeaders((name) =>
  ///     name.toLowerCase() == 'authorization' ||
  ///     name.toLowerCase() == 'x-api-key'
  ///   );
  /// ```
  HttpClientBuilder redactLoggedHeaders(
    bool Function(String headerName) shouldRedact,
  ) {
    services.configure<HttpClientFactoryOptions>(
      HttpClientFactoryOptions.new,
      (options) => options.shouldRedactHeaderValue = shouldRedact,
      name: name,
    );
    return this;
  }

  /// Configures specific header names to be redacted in logs.
  ///
  /// Example:
  /// ```dart
  /// services.addHttpClient('MyClient')
  ///   .redactLoggedHeaderNames(['Authorization', 'X-Api-Key']);
  /// ```
  HttpClientBuilder redactLoggedHeaderNames(List<String> headerNames) {
    final lowerCaseNames =
        headerNames.map((n) => n.toLowerCase()).toSet();
    return redactLoggedHeaders(
      (name) => lowerCaseNames.contains(name.toLowerCase()),
    );
  }

  /// Sets the handler lifetime for this HTTP client.
  ///
  /// The handler will be recreated after the specified duration.
  /// A zero or negative duration disables expiration.
  HttpClientBuilder setHandlerLifetime(Duration lifetime) {
    services.configure<HttpClientFactoryOptions>(
      HttpClientFactoryOptions.new,
      (options) => options.handlerLifetime = lifetime,
      name: name,
    );
    return this;
  }
}
