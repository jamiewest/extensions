import '../options/options.dart';
import 'http_message_handler.dart';

abstract class HttpMessageHandlerFactory {
  HttpMessageHandler createHandler([String? name = Options.defaultName]);
}
