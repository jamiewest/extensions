import 'package:http/http.dart' as http;

import '../dependency_injection/service_collection.dart';
import '../dependency_injection/service_collection_descriptor_extensions.dart';
import '../dependency_injection/service_descriptor.dart';
import '../dependency_injection/service_provider.dart';
import '../dependency_injection/service_provider_service_extensions.dart';
import '../options/options.dart';
import '../options/options_monitor.dart';
import '../options/options_service_collection_extensions.dart';
import 'default_http_client_factory.dart';
import 'default_http_message_handler_factory.dart';
import 'http_client_builder.dart';
import 'http_client_factory.dart';
import 'http_client_factory_options.dart';
import 'http_message_handler_factory.dart';

/// ServiceCollection extensions for configuring HTTP clients.
extension HttpClientFactoryServiceCollectionExtensions on ServiceCollection {
  /// Registers the default HTTP client factory for a named client.
  HttpClientBuilder addHttpClient([String name = Options.defaultName]) {
    _addHttpClientCore();
    addOptions<HttpClientFactoryOptions>(
      HttpClientFactoryOptions.new,
      name: name,
    );
    return HttpClientBuilder(this, name);
  }

  /// Registers a typed client bound to the named client.
  HttpClientBuilder addHttpClientTyped<TClient extends Object>(
    TClient Function(
      http.BaseClient client,
      ServiceProvider services,
    ) factory, {
    String name = Options.defaultName,
  }) =>
      addHttpClient(name)..addTypedClient<TClient>(factory);

  void _addHttpClientCore() {
    tryAdd(
      ServiceDescriptor.singleton<HttpMessageHandlerFactory>(
        (sp) => DefaultHttpMessageHandlerFactory(
          sp,
          sp.getRequiredService<OptionsMonitor<HttpClientFactoryOptions>>(),
        ),
      ),
    );

    tryAdd(
      ServiceDescriptor.singleton<HttpClientFactory>(
        (sp) => DefaultHttpClientFactory(
          sp,
          sp.getRequiredService<HttpMessageHandlerFactory>(),
          sp.getRequiredService<OptionsMonitor<HttpClientFactoryOptions>>(),
        ),
      ),
    );
  }
}
