import '../system/exceptions/invalid_operation_exception.dart';

class Throw {
  static InvalidOperationException createMissingServiceException(
    Type serviceType,
    Object? serviceKey,
  ) =>
      InvalidOperationException(
        message: serviceKey == null
            ? 'No service of type '
                "'$serviceType' is available."
            : 'No service of type '
                "'$serviceType' for the key "
                "'$serviceKey' is available.",
      );
}
