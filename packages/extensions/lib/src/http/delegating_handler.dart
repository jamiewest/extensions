import 'package:http/http.dart' as http;
import '../system/exceptions/invalid_operation_exception.dart';
import 'http_message_handler.dart';

/// Base class for composing HTTP handlers into a pipeline.
abstract class DelegatingHandler implements HttpMessageHandler {
  DelegatingHandler([HttpMessageHandler? innerHandler])
      : _innerHandler = innerHandler;

  HttpMessageHandler? _innerHandler;
  bool _operationStarted = false;
  bool _disposed = false;

  HttpMessageHandler? get innerHandler => _innerHandler;

  set innerHandler(HttpMessageHandler? value) {
    _checkDisposedOrStarted();
    _innerHandler = value;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    _setOperationStarted();
    return _innerHandler!.send(request);
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _innerHandler?.dispose();
  }

  void _checkDisposedOrStarted() {
    if (_operationStarted) {
      throw InvalidOperationException(
        message: 'SR.net_http_operation_started',
      );
    }
  }

  void _setOperationStarted() {
    if (_innerHandler == null) {
      throw InvalidOperationException(
        message: 'SR.net_http_handler_not_assigned',
      );
    }

    if (!_operationStarted) {
      _operationStarted = true;
    }
  }
}
