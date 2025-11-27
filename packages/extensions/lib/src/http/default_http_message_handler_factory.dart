import '../dependency_injection/service_provider.dart';
import '../dependency_injection/service_provider_service_extensions.dart';
import '../options/options.dart';
import '../options/options_monitor.dart';
import 'default_http_message_handler_builder.dart';
import 'http_client_factory_options.dart';
import 'http_message_handler.dart';
import 'http_message_handler_builder.dart';
import 'http_message_handler_builder_filter.dart';
import 'http_message_handler_factory.dart';

/// Builds message handlers for named HTTP clients.
class DefaultHttpMessageHandlerFactory implements HttpMessageHandlerFactory {
  DefaultHttpMessageHandlerFactory(
    this._services,
    this._optionsMonitor,
  );

  final ServiceProvider _services;
  final OptionsMonitor<HttpClientFactoryOptions> _optionsMonitor;

  @override
  HttpMessageHandler createHandler([String? name = Options.defaultName]) {
    var options = _optionsMonitor.get(name);

    var builder = DefaultHttpMessageHandlerBuilder(_services)..name = name;

    // Apply builder actions
    for (var action in options.httpMessageHandlerBuilderActions) {
      action(builder, _services);
    }

    // Set default primary handler if not already set
    builder.primaryHandler ??= DefaultHttpClientHandler();

    // Apply filters using a chain of responsibility pattern
    final filters =
        _services.getServices<HttpMessageHandlerBuilderFilter>().toList();

    // Build filter chain in reverse order
    var chain = (HttpMessageHandlerBuilder b) {
      // Terminal operation - do nothing
    };

    for (final filter in filters.reversed) {
      final currentChain = chain;
      chain = (HttpMessageHandlerBuilder b) {
        filter.configure(currentChain, b);
      };
    }

    // Execute the filter chain
    chain(builder);

    return builder.build();
  }
}
