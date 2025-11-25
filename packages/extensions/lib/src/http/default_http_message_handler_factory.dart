import '../dependency_injection/service_provider.dart';
import '../options/options.dart';
import '../options/options_monitor.dart';
import 'default_http_message_handler_builder.dart';
import 'http_client_factory_options.dart';
import 'http_message_handler.dart';
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

    for (var action in options.httpMessageHandlerBuilderActions) {
      action(builder, _services);
    }

    builder.primaryHandler ??= DefaultHttpClientHandler();

    return builder.build();
  }
}
