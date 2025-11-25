import '../../system/exceptions/object_disposed_exception.dart';

class ThrowHelper {
  static void throwObjectDisposedException() {
    throw ObjectDisposedException(objectName: 'ServiceProvider');
  }
}
