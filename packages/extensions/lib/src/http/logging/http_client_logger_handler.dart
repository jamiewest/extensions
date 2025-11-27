import 'package:http/http.dart';

import '../delegating_handler.dart';

sealed class HttpClientLoggerHandler extends DelegatingHandler {
  @override
  Future<StreamedResponse> send(BaseRequest request) {
    return super.send(request);
  }
}
