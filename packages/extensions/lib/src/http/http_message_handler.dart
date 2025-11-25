import 'package:http/http.dart' as http;

import '../system/disposable.dart';

abstract class HttpMessageHandler implements Disposable {
  Future<http.StreamedResponse> send(http.BaseRequest request);
}
