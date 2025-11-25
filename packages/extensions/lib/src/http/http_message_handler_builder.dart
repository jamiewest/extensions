import '../dependency_injection/service_provider.dart';
import 'delegating_handler.dart';
import 'http_message_handler.dart';

abstract class HttpMessageHandlerBuilder {
  String? name;

  HttpMessageHandler? primaryHandler;

  List<DelegatingHandler> get additionalHandlers;

  ServiceProvider get services;

  HttpMessageHandler build();
}
